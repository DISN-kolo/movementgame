extends Node3D
## see also: chars/climb_casts.gd
class_name LowVaultCastsNode;

var actual_raycasts: Array[RayCast3D] = [null, null, null];
var yes_collision: bool = false;
var top_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var collided_object: Object = null;

@onready var low_vault_cast_1: RayCast3D = $LowVaultCast1;
@onready var low_vault_cast_2: RayCast3D = $LowVaultCast2;
@onready var low_vault_cast_3: RayCast3D = $LowVaultCast3;

const WANNA_BE_LOW_VAULTED_UP_CHECKER = preload("res://chars/wanna_be_low_vaulted_up_checker.tscn");
var wb_lvu_instance: Area3D = null;

# TODO
# three behaviors: 
# 1. step-up onto the platform (conserve speed)
# 
#        ====>
#                  ·` ` ` ` `
#                  ·
#          /```````:````````` (same h or the last segment is higher)
#          |       :
# ........./       :
# 
# 1.1. shall the step-up be different for idle vs walk vs jump/fall?
# 1.2. I think it's better to NOT do a step-up from idle.
# 2. step-over (maybe allow for a boosted jump if key pushed again)
#
#        ====>
# 
#          /```````\          
#          |       :````````` (lower h, but not below the original floor)
# ........./       :
# 
# 3. jump-over-edge-ledge (the state afterwards must be some sort
#of a jump-boost 100%, not 'if the player presses stuff')
#
#        ====>
# 
#          /```````\          
#          |       |
# ........./       |          (below the original floor or nothing at all)
#                  |
# . . . . . . . . .|. . . . . .
#  # # # # # # # # | # # # # # 
# #################|###########
#
# the process:
# 1. do the typical 3-raycasts-in-front to detect the furthest
#available sticking-out-thing
# 2. spawn a capsule there and check if the top part of the potential vault
#path is available. if not, abandon the idea of vaulting.
# 3. add a fixed distance to that collpoint, equivalent to maybe 1.5 radii of
#player's coll capsule. maybe speed-affected?. run a topdown raycast there.
# 4. if the raycast hit, see which height thing happens in the previously
#discussed scenarios. if the raycast doesn't hit, it's the third scenario
#as well.
# 5. if the scenario is the first one, do the simple vault-up.
# 6. if the scenario is the second one, spawn a capsule in the collpoint of
#(3). if it's occupied, do a simple vault-up. if it's not occupied, do the
#vault-over. if during the vault-over the jump is pressed again, do a
#boosted jump.
# 7. if the scenario is the third one, do a forced boosted jump (maybe
#change later to regular vault with optional vault-jump on user press)

func _ready() -> void:
	var i: int = 0;
	for child in get_children():
		actual_raycasts[i] = child;
		i += 1;

func stepup_space_available() -> bool:
	print(wb_lvu_instance)
	if (wb_lvu_instance == null):
		return false;
	if (wb_lvu_instance.has_overlapping_bodies()):
		return false;
	return true;

func completely_prepare_stepup() -> void:
	rm_old_wb_lvus();
	calc_nearest_lv_coll();
	spawn_wb_lvu_checker();

func rm_old_wb_lvus() -> void:
	var worldnode = get_tree().get_first_node_in_group("worldnode");
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_lvu_area")):
			print("detected wb_lvu, rming");
			wn_child.free();

func spawn_wb_lvu_checker() -> void:
	if (!yes_collision):
		return ;
	wb_lvu_instance = WANNA_BE_LOW_VAULTED_UP_CHECKER.instantiate();
	var worldnode = get_tree().get_first_node_in_group("worldnode");
	worldnode.add_child(wb_lvu_instance);
	wb_lvu_instance.global_position = top_col_pos;

func calc_nearest_lv_coll() -> void:
	var casts: Array[bool] = check_all();
	var index: int = 0;
	while (index < 3):
		if (casts[index] == true):
			yes_collision = true;
			break;
		index += 1;
	if (index == 3):
		yes_collision = false;
		return ;
	collided_object = actual_raycasts[index];
	top_col_pos = actual_raycasts[index].get_collision_point();
	print("co:  ", collided_object);
	print("tcp: ", top_col_pos);

func check_all() -> Array[bool]:
	# XXX one day expand to more than three? lol
	var casts: Array[bool] = [false, false, false];
	var i: int = 0;
	for cast in actual_raycasts:
		casts[i] = one_cast_check(cast);
		i += 1;
	return casts;

func one_cast_check(cast: RayCast3D) -> bool:
	cast.force_raycast_update();
	return cast.is_colliding();
