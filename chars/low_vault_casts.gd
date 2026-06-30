extends Node3D
## see also: chars/climb_casts.gd
class_name LowVaultCastsNode;

var actual_raycasts: Array[RayCast3D] = [null, null, null];
var yes_collision: bool = false;
var top_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var collided_object: Object = null;

var lvu_pos: Vector3 = Vector3(NAN, NAN, NAN);
var through_pos: Vector3 = Vector3(NAN, NAN, NAN);

var lvu_overlaps: bool = true;
var through_overlaps: bool = true;

@onready var low_vault_cast_1: RayCast3D = $LowVaultCast1;
@onready var low_vault_cast_2: RayCast3D = $LowVaultCast2;
@onready var low_vault_cast_3: RayCast3D = $LowVaultCast3;

@onready var aux_cast: RayCast3D = %LowVaultCastAux;
var aux_hit: bool = false;

const WANNA_BE_LOW_VAULTED_UP_CHECKER = preload("res://chars/wanna_be_low_vaulted_up_checker.tscn");
var wb_lvu_instance: Area3D = null;

const WANNA_BE_THROUGH_CHECKER = preload("res://chars/wanna_be_through_checker.tscn");
var wb_through_instance: Area3D = null;

var scenario_chosen: int = 0;

var worldnode;

# TODO
# ray hit?
# no:
#   capsule 2 intersects?
#   no:
#     vault over
#   yes:
#     then this ray is inside some geometry or it's weird, just jump
# yes:
#   height?
#   below half-point between floor and init top col height:
#     vault over
#   below half-height of player:
#     step up to that ray hit's pos
#   above:
#     just jump
#
# why have intermediate capsule area? for checking the animated path's validity.
# cuz if it's not valid, don't animate the vault!
#
# use shift for something more useful like a different vault mode instead
# of controlling the run state?
# idea by https://git.gay/Hylus5d10

func _ready() -> void:
	worldnode = get_tree().get_first_node_in_group("worldnode");
	var i: int = 0;
	for child in get_children():
		if (child.is_in_group("aux_cast")):
			continue ;
		actual_raycasts[i] = child;
		i += 1;

func stepup_space_available() -> bool:
	#print(wb_lvu_instance)
	if (wb_lvu_instance == null):
		return false;
	if (wb_lvu_instance.has_overlapping_bodies()):
		return false;
	return true;

func completely_prepare_stepup() -> void:
	rm_old_wb_lvus();
	rm_old_wb_throughs();
	calc_nearest_lv_coll();
	spawn_wb_lvu_checker();
	if (!yes_collision):
		return ;
	aux_raycast_checking()
	spawn_wb_through_checker();

func rm_old_wb_lvus() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_lvu_area")):
			wn_child.free();

func spawn_wb_lvu_checker() -> void:
	if (!yes_collision):
		return ;
	wb_lvu_instance = WANNA_BE_LOW_VAULTED_UP_CHECKER.instantiate();
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

func check_all() -> Array[bool]:
	var casts: Array[bool] = [false, false, false];
	var i: int = 0;
	for cast in actual_raycasts:
		casts[i] = one_cast_check(cast);
		i += 1;
	return casts;

func one_cast_check(cast: RayCast3D) -> bool:
	cast.force_raycast_update();
	return cast.is_colliding();

func aux_raycast_checking() -> void:
	aux_cast.force_raycast_update();
	if (aux_cast.get_collider() == null):
		print("no coll! vault or wall.");
		aux_hit = false;
	else:
		print("yes coll:");
		aux_hit = true;
		print(aux_cast.get_collision_normal());
		print(aux_cast.get_collision_point());

func rm_old_wb_throughs() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_through_area")):
			wn_child.free();

func spawn_wb_through_checker() -> void:
	wb_through_instance = WANNA_BE_THROUGH_CHECKER.instantiate();
	worldnode.add_child(wb_through_instance);
	if (aux_hit):
		wb_through_instance.global_position = aux_cast.get_collision_point();
	else:
		wb_through_instance.global_position = aux_cast.global_position - Vector3(0, 2, 0);

func there_is_wb_lvu() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_lvu_area")):
			return true;
	return false;

func there_is_wb_through() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_through_area")):
			return true;
	return false;

func calculate_areas_overlap() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	var wannabe_lvu_actual: Area3D = null;
	var wannabe_through_actual: Area3D = null;
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_lvu_area")):
			wannabe_lvu_actual = wn_child;
			lvu_pos = wannabe_lvu_actual.global_position;
		elif (wn_child.is_in_group("wb_through_area")):
			wannabe_through_actual = wn_child;
			through_pos = wannabe_through_actual.global_position;
	await get_tree().physics_frame;
	if (wannabe_lvu_actual != null):
		lvu_overlaps = wannabe_lvu_actual.has_overlapping_bodies();
	if (wannabe_through_actual != null):
		through_overlaps = wannabe_through_actual.has_overlapping_bodies();
	print("OVS CALCD");
