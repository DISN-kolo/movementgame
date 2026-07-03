extends Node3D
class_name ClimbCastsNode;

@onready var climb_cast_top_1: RayCast3D = $ClimbCastTop1;
@onready var climb_cast_top_2: RayCast3D = $ClimbCastTop2;
@onready var climb_cast_top_3: RayCast3D = $ClimbCastTop3;
var collision_shape_3d: CollisionShape3D;
const WANNA_BE_HANGING_LEDGE_CHECKER = preload("uid://c1sjg3ntf4qbe");

var pc: Player;

var wb_actual_position: Vector3 = Vector3(NAN, NAN, NAN);
@onready var wannabeup_ps = preload("res://chars/wanna_be_up_checker.tscn");
var wannabeup: Area3D;
var climbing_space_available: bool = false;
var ending_position: Vector3;

var worldnode: Node;

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
	worldnode = get_tree().get_first_node_in_group("worldnode");
	positioned_ledger.connect(do_the_top_of_climb_check);
	Signals.move_top_col_pos.connect(move_top_col_pos);
	var i: int = 0;
	for child in get_children():
		actual_raycasts[i] = child;
		i += 1;

## spawns and positions an area which imitates where one would be if trying
## to ledge oneself by onto what they're looking at. the area is in group
## [code]wannabe_ledged_area[/code].
func completely_prepare_ledging() -> void:
	remove_old_wb_ledged();
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
	# XXX one day expand to more than three? lol
	var casts: Array[bool] = [false, false, false];
	var i: int = 0;
	for cast in actual_raycasts:
		casts[i] = one_cast_check(cast);
		i += 1;
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
	#=============================================================
	#           H - ?; H = T + TH;
	# T o_                     TH = TR.projected_onto(norm);
	#   |  ` =,                     TR = R - T;
	#   |       ` =,   R      a.p_o(n) = n*cos(a..n)*a = a.dot(n);
	#---o------------`o---
	#  H              |
	#                 V norm
	#
	# thus, see below. R = raw, T = top col, H = hor col.
	var raw: Vector3 = result.get("position");
	hor_col_norm = result.get("normal");
	hor_col_norm_backup = hor_col_norm;
	var projected: Vector3 = top_col_pos + hor_col_norm * hor_col_norm.dot(raw - top_col_pos);
	hor_col_pos = projected;
	hor_col_pos.y = raw.y;

## gets the normal of the collision with the wall as the starting point
## in molding the area's position. using pre-calculated stuff that shall depend
## entirely on what's feasible for a character to look like while ledge-grabbing,
## position the area relative to the horizontal collision position.
func spawn_and_position_area() -> void:
	hor_col_norm *= Vector3(0.6, 1, 0.6);
	hor_col_norm.y -= 1.3;
	var scanner_area_location: Vector3 = hor_col_pos + hor_col_norm;
	var new_wanna_be_instance = WANNA_BE_HANGING_LEDGE_CHECKER.instantiate();
	worldnode.add_child(new_wanna_be_instance);
	new_wanna_be_instance.global_position = scanner_area_location;



## respawns the "this is where you'd be if climbed" checker and checks it,
## storing the result in the [member ClimbCastsNode.climbing_space_available].
func do_the_top_of_climb_check() -> void:
	remove_old_wb_ups();
	spawn_wb_up();
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_up_area")):
			wannabeup = wn_child;
			break ;
	await get_tree().physics_frame;
	if (wannabeup.has_overlapping_bodies()):
		climbing_space_available = false;
	else:
		climbing_space_available = true;

## this will remove all old wannabeup checkers that could still
## be left standing around. wannabeup == the capsule that's on top of the
## potentially climbable surface.
func remove_old_wb_ups() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_up_area")):
			wn_child.free();

func spawn_wb_up() -> void:
	ending_position = (top_col_pos
		+ Vector3(0, pc.default_capsule_height/2, 0));
	wannabeup = wannabeup_ps.instantiate();
	worldnode.add_child(wannabeup);
	wannabeup.global_position = ending_position;

## this will remove all old wannabeledged checkers that could still
## be left hanging around. wannabeledged == the capsule that's imitating
## what it'd be like to hang onto a ledge.
func remove_old_wb_ledged() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_ledged_area")):
			wn_child.free();

func there_is_wb_ledged() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_ledged_area")):
			return true;
	return false;

func is_wb_ledged_below() -> bool:
	return (wb_actual_position.y <= pc.position.y);

func ledging_space_available() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	var wannabe_actual: Area3D = null;
	var succeeded: bool = false;
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_ledged_area")):
			succeeded = true;
			wannabe_actual = wn_child;
			break ;
	if (!succeeded):
		return false;
	wb_actual_position = wannabe_actual.global_position;
	await get_tree().physics_frame;
	if (wannabe_actual.has_overlapping_bodies()):
		return false;
	return true;
