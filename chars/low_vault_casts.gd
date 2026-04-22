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

# TODO
# three behaviors: 
# 1. step-up
# 2. step-over (maybe allow for a boosted jump if key pushed again)
# 3. jump-over-edge-ledge (the state afterwards must be some sort
#of a jump-boost)
# these behaviors need:
# 1. check for any initial collision, the closer the more priority (like top)
# 2. check if there's a fall-able gap after the collision (using an area)
# 3. check if there's space to vault into
# XXX this lowcast thing etc should have priority over ledging stuff
# maybe the area checks with async will fuck it up, but in theory
#putting it before all the climb stuff in "process"es of states
#should result in correct order of checks.

func _ready() -> void:
	var i: int = 0;
	for child in get_children():
		actual_raycasts[i] = child;
		i += 1;

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
