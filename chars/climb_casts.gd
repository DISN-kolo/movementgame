extends Node3D
@onready var climb_cast_top_1: RayCast3D = $ClimbCastTop1;
@onready var climb_cast_top_2: RayCast3D = $ClimbCastTop2;
@onready var climb_cast_top_3: RayCast3D = $ClimbCastTop3;
@onready var collision_shape_3d: CollisionShape3D = $"../../CollisionShape3D";
const WANNA_BE_HANGING_LEDGE_CHECKER = preload("uid://c1sjg3ntf4qbe");

var actual_raycasts: Array[RayCast3D] = [null, null, null];
var yes_collision: bool = false;
var top_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var hor_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var collided_object: Object = null;

func _ready() -> void:
	actual_raycasts[0] = climb_cast_top_1;
	actual_raycasts[1] = climb_cast_top_2;
	actual_raycasts[2] = climb_cast_top_3;

func calc_horizontal_coll_point():
	calc_nearest_top_coll();
	if !yes_collision:
		return ;
	var space_state = get_world_3d().direct_space_state;
	var origin: Vector3 = self.global_position;
	var end: Vector3 = top_col_pos;
	end.y -= 0.01;
	origin.y = end.y;
	var query = PhysicsRayQueryParameters3D.create(origin, end);
	query.exclude = [collision_shape_3d];
	var result = space_state.intersect_ray(query);
	if result.is_empty():
		yes_collision = false;
		return ;
	hor_col_pos = result.get("position");
	var hor_col_norm = result.get("normal");
	position_the_area(hor_col_norm);

func position_the_area(hor_col_norm: Vector3):
	hor_col_norm *= Vector3(0.6, 1, 0.6);
	hor_col_norm.y -= 1.3;
	var scanner_area_location: Vector3 = hor_col_pos + hor_col_norm;
	var new_wanna_be_instance = WANNA_BE_HANGING_LEDGE_CHECKER.instantiate();
	new_wanna_be_instance.global_position = scanner_area_location;
	var worldnode = get_tree().get_first_node_in_group("worldnode");
	worldnode.add_child(new_wanna_be_instance);
	

func calc_nearest_top_coll():
	var casts: Array[bool] = check_all();
	var index: int = 0;
	while index < 3:
		if casts[index] == true:
			yes_collision = true;
			break;
		index += 1;
	if index == 3:
		yes_collision = false;
		return ;
	collided_object = actual_raycasts[index];
	top_col_pos = actual_raycasts[index].get_collision_point();

func check_all() -> Array[bool]:
	var casts: Array[bool] = [false, false, false];
	climb_cast_top_1.force_raycast_update();
	casts[0] = climb_cast_top_1.is_colliding();
	climb_cast_top_2.force_raycast_update();
	casts[1] = climb_cast_top_2.is_colliding();
	climb_cast_top_3.force_raycast_update();
	casts[2] = climb_cast_top_3.is_colliding();
	return casts;
