extends Node3D
class_name ClimbCastsNode;

@onready var climb_cast_top_1: RayCast3D = $ClimbCastTop1;
@onready var climb_cast_top_2: RayCast3D = $ClimbCastTop2;
@onready var climb_cast_top_3: RayCast3D = $ClimbCastTop3;
@onready var collision_shape_3d: CollisionShape3D = $"../../CollisionShape3D";
const WANNA_BE_HANGING_LEDGE_CHECKER = preload("uid://c1sjg3ntf4qbe");

var hopped_from_rid: RID = RID();
var latest_rid: RID = RID();
var is_hopping: bool = false;

var actual_raycasts: Array[RayCast3D] = [null, null, null];
var yes_collision: bool = false;
var top_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var hor_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var hor_col_norm_backup: Vector3 = Vector3(NAN, NAN, NAN);
var hor_col_norm: Vector3 = Vector3(NAN, NAN, NAN);
var collided_object: Object = null;

signal positioned_ledger;

func move_top_col_pos(nextpos: Vector3) -> void:
	top_col_pos = nextpos;

func _ready() -> void:
	Signals.move_top_col_pos.connect(move_top_col_pos);
	actual_raycasts[0] = climb_cast_top_1;
	actual_raycasts[1] = climb_cast_top_2;
	actual_raycasts[2] = climb_cast_top_3;

func completely_prepare_ledging() -> void:
	calc_nearest_top_coll();
	if (!yes_collision):
		return ;
	calc_hor_col();
	spawn_and_position_area();
	positioned_ledger.emit();

## run through all three raycasts. get the closest colliding one,
## and get its info into the objects variable (collision coordinate,
## what object)
func calc_nearest_top_coll() -> void:
	var casts: Array[bool] = check_all();
	var index: int = 0;
	while (index < 3):
		if (casts[index] == true):
			yes_collision = true;
			break;
		index += 1;
	if (index == 3):
		yes_collision = false;
		latest_rid = RID();
		return ;
	collided_object = actual_raycasts[index];
	latest_rid = collided_object.get_collider_rid();
	top_col_pos = actual_raycasts[index].get_collision_point();

func check_all() -> Array[bool]:
	var casts: Array[bool] = [false, false, false];
	casts[0] = one_cast_check(climb_cast_top_1);
	casts[1] = one_cast_check(climb_cast_top_2);
	casts[2] = one_cast_check(climb_cast_top_3);
	return casts;

func one_cast_check(cast: RayCast3D) -> bool:
	cast.force_raycast_update();
	if (is_hopping and hopped_from_rid.is_valid() and cast.get_collider_rid() == hopped_from_rid):
		return false;
	else:
		return cast.is_colliding();

## go a bit below the collision point of the chosen topdown raycast's collision.
## this should be inside of the object we're colliding with in the first place.
## will return failure on super thin stuff. barring that, run a raycast
## in the xz direction of the wall from the player. get its data (pos & norm) into
## object's variables.
func calc_hor_col() -> void:
	var space_state = get_world_3d().direct_space_state;
	var origin: Vector3 = global_position;
	var end: Vector3 = top_col_pos;
	end.y -= 0.01;
	origin.y = end.y;
	var query = PhysicsRayQueryParameters3D.create(origin, end);
	query.exclude = [collision_shape_3d];
	var result = space_state.intersect_ray(query);
	if (result.is_empty()):
		yes_collision = false;
		return ;
	hor_col_pos = result.get("position");
	hor_col_norm = result.get("normal");
	hor_col_norm_backup = hor_col_norm;

## gets the normal of the collision with the wall as the starting point
## in molding the area's position. using pre-calculated stuff that shall depend
## entirely on what's feasible for a character to look like while ledge-grabbing,
## position the area relative to the horizontal collision position.
func spawn_and_position_area() -> void:
	hor_col_norm *= Vector3(0.6, 1, 0.6);
	hor_col_norm.y -= 1.3;
	var scanner_area_location: Vector3 = hor_col_pos + hor_col_norm;
	var new_wanna_be_instance = WANNA_BE_HANGING_LEDGE_CHECKER.instantiate();
	new_wanna_be_instance.position = scanner_area_location;
	var worldnode = get_tree().get_first_node_in_group("worldnode");
	worldnode.add_child(new_wanna_be_instance);
