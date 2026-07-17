extends Node3D
## see also: chars/climb_casts.gd
class_name LowVaultCastsNode;

var actual_raycasts: Array[RayCast3D] = [null, null, null];
var yes_collision: bool = false;
var top_col_pos: Vector3 = Vector3(NAN, NAN, NAN);
var collided_object: Object = null;
var collided_index: int = -1;
var latest_rid: RID = RID();

var lvu_pos: Vector3 = Vector3(NAN, NAN, NAN);
var safe_landing_pos: Vector3 = Vector3(NAN, NAN, NAN);

var lvu_overlaps: bool = true;

@onready var low_vault_cast_1: RayCast3D = $LowVaultCast1;
@onready var low_vault_cast_2: RayCast3D = $LowVaultCast2;
@onready var low_vault_cast_3: RayCast3D = $LowVaultCast3;

@onready var aux_cast: RayCast3D = %LowVaultCastAux;
var aux_hit: bool = false;
var is_shallow_flat_obstacle: bool = false;
var aux_blocked_by_wall: bool = false;

enum SweepKind { NONE, WALL_CHECK, LANDING };
var last_sweep_kind: SweepKind = SweepKind.NONE;
var last_sweep_result: bool = false;

var pc: Player;

const WANNA_BE_LOW_VAULTED_UP_CHECKER = preload("res://chars/wanna_be_low_vaulted_up_checker.tscn");
var wb_lvu_instance: Area3D = null;

var scenario_chosen: int = 0;

enum FirstPartCondition { NO_COLL, BELOW_QUARTER, BELOW_HALF_ABOVE_QUARTER };
enum SecondPartCondition { NO_COLL, BELOW_QUARTER_UNTIL_FLOOR, BELOW_HALF_ABOVE_QUARTER, ABOVE_HALF };

var saved_fp_condition: FirstPartCondition = FirstPartCondition.NO_COLL;
var saved_sp_condition: SecondPartCondition = SecondPartCondition.NO_COLL;

var worldnode;

# TODO
#
# first part is:
# 1. below quarter
#   second part is:
#   a. below floor level
#     edge-jump
#   b. below qurter, until floor level (including)
#     step-over
#   c. below half, above quarter
#     vault-(through)-up (how? what off? maybe just jump?
#     looks super uncomfortable, like a wall ("above half"))
#   d. above half
#     just jump
# 2. below half, above quarter
#   second part is:
#   a. below floor level
#     edge-jump
#   b. below qurter, until floor level (including)
#     vault-over
#   c. below half, above quarter
#     vault-(through)-up
#   d. above half
#     vault-up (not "through")
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
	if (wb_lvu_instance == null):
		return false;
	if (wb_lvu_instance.has_overlapping_bodies()):
		return false;
	return true;

func prepare_stepup_stage_one() -> void:
	last_sweep_kind = SweepKind.NONE;
	last_sweep_result = false;
	rm_old_wb_lvus();
	calc_nearest_lv_coll();
	spawn_wb_lvu_checker();

func prepare_stepup_stage_two() -> void:
	if (!yes_collision):
		return ;
	if (lvu_overlaps):
		return ;
	aux_raycast_checking();
	if (aux_hit && !is_shallow_flat_obstacle):
		calc_safe_landing_pos();

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
		collided_index = -1;
		latest_rid = RID();
		return ;
	collided_index = index;
	collided_object = actual_raycasts[index];
	latest_rid = collided_object.get_collider_rid();
	top_col_pos = actual_raycasts[index].get_collision_point();

func classify_first_part() -> FirstPartCondition:
	if (!yes_collision):
		return FirstPartCondition.NO_COLL;
	var local_y: float = top_col_pos.y - pc.global_position.y;
	var quarter_y: float = -pc.default_capsule_height / 4.0;
	if (local_y < quarter_y):
		return FirstPartCondition.BELOW_QUARTER;
	else:
		return FirstPartCondition.BELOW_HALF_ABOVE_QUARTER;

func classify_second_part() -> SecondPartCondition:
	if (!aux_hit):
		# TODO additional check of why no coll
		return SecondPartCondition.NO_COLL;
	var local_y: float = aux_cast.get_collision_point().y - pc.global_position.y;
	var quarter_y: float = -pc.default_capsule_height / 4.0;
	if (local_y < quarter_y):
		return SecondPartCondition.BELOW_QUARTER_UNTIL_FLOOR;
	elif (local_y < 0.0):
		return SecondPartCondition.BELOW_HALF_ABOVE_QUARTER;
	else:
		return SecondPartCondition.ABOVE_HALF;

func run_and_save_first_classify() -> void:
	saved_fp_condition = classify_first_part();

func run_and_save_second_classify() -> void:
	if (is_shallow_flat_obstacle):
		return ;
	saved_sp_condition = classify_second_part();

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

func position_aux_cast() -> void:
	var collided_ray: RayCast3D = actual_raycasts[collided_index];
	var capsule_diameter: float = pc.default_capsule_radius * 2.0;
	aux_cast.position.x = collided_ray.position.x;
	aux_cast.position.z = collided_ray.position.z - 1.5 * capsule_diameter;

func aux_raycast_checking() -> void:
	position_aux_cast();
	aux_cast.force_raycast_update();
	if (aux_cast.get_collider() == null):
		print("no coll! vault or wall.");
		aux_hit = false;
		is_shallow_flat_obstacle = false;
		var result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new();
		var sweep_target: Vector3 = aux_cast.to_global(aux_cast.target_position);
		sweep_target.y = top_col_pos.y;
		aux_blocked_by_wall = sweep_from_top_col(sweep_target, [], result, SweepKind.WALL_CHECK);
		return ;
	print("yes coll:");
	aux_hit = true;
	is_shallow_flat_obstacle = (aux_cast.get_collider_rid() == latest_rid);
	print(aux_cast.get_collision_normal());
	print(aux_cast.get_collision_point());

## sweeps the player's own capsule from [member top_col_pos] to target.
## any overlap at the start is a collision too (which surprisingly isn't default,
## see [member PhysicsTestMotionParameters3D.recovery_as_collision]). obviously
## you have to exclude the ledge we're on since it'll often clip the bottom
## of the capsule
func sweep_from_top_col(target: Vector3, exclude: Array[RID], result: PhysicsTestMotionResult3D, kind: SweepKind) -> bool:
	var params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new();
	var capsule_feet_offset: Vector3 = Vector3(0, pc.default_capsule_height / 2.0, 0);
	params.from = Transform3D(pc.global_transform.basis, top_col_pos + capsule_feet_offset);
	params.motion = target - top_col_pos;
	params.recovery_as_collision = true;
	params.exclude_bodies = exclude;
	last_sweep_kind = kind;
	last_sweep_result = PhysicsServer3D.body_test_motion(pc.get_rid(), params, result);
	ping_collider(result.get_collider());
	return last_sweep_result;

func ping_collider(c: Node3D) -> void:
	if (!c):
		return ;
	if (!c.has_method("get_material")):
		return ;
	var mat: Material = c.get_material();
	if (!(mat is StandardMaterial3D)):
		return ;
	var std_mat: StandardMaterial3D = mat.duplicate();
	c.set_material(std_mat);
	var original_color: Color = std_mat.albedo_color;
	var tween: Tween = create_tween();
	tween.tween_property(std_mat, "albedo_color", Color.WHITE, 0.1);
	tween.tween_property(std_mat, "albedo_color", original_color, 0.1);

func calc_safe_landing_pos() -> void:
	var result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new();
	if (sweep_from_top_col(aux_cast.get_collision_point(), [latest_rid], result, SweepKind.LANDING)):
		safe_landing_pos = top_col_pos + result.get_travel();
	else:
		safe_landing_pos = aux_cast.get_collision_point();
	print(safe_landing_pos);

func there_is_wb_lvu() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_lvu_area")):
			return true;
	return false;

func calculate_area_overlap() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	var wannabe_lvu_actual: Area3D = null;
	for wn_child in wn_children:
		if (wn_child.is_in_group("wb_lvu_area")):
			wannabe_lvu_actual = wn_child;
			lvu_pos = wannabe_lvu_actual.global_position;
			break ;
	if (wannabe_lvu_actual != null):
		await get_tree().physics_frame;
		lvu_overlaps = wannabe_lvu_actual.has_overlapping_bodies();
		print("OVS CALCD: ", lvu_overlaps);
