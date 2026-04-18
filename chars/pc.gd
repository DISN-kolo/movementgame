extends CharacterBody3D;
class_name Player;

@onready var above_raycast: RayCast3D = %AboveRaycast;

@onready var head_pc: Node3D = %HeadPC;
@onready var camera_pc: Camera3D = %HeadPC/CameraPC;
@onready var label_state: Label = $MainControl/LabelState;
@onready var label_r_state: Label = $MainControl/LabelRState;
@onready var label_c_state: Label = $MainControl/LabelCState;
@onready var label_misc: Label = $MainControl/LabelMisc;

@onready var controllers: Node = %Controllers;

@onready var state_machine: StateMachine = $Controllers/StateMachine;
@onready var run_machine: StateMachine = $Controllers/RunMachine;

@onready var run_state: State = $Controllers/RunMachine/Run;
@onready var non_run_state: State = $Controllers/RunMachine/NonRun;

@onready var crouch_machine: StateMachine = $Controllers/CrouchMachine;

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D;
@onready var climb_casts: ClimbCastsNode = %ClimbCasts;
@onready var hand_casts: HandCasts = %HandCasts;

var fov_default : float = 85;
var fov_speed_proportion_minimum : float = 0.1;
var bob_speed_proportion_minimum : float = 0.2;
var bob_t : float = 0;

# related to crouching
var default_head_y : float;
var lower_head_y : float;
var current_head_y : float;
var default_capsule_height : float;
var crouched_capsule_height : float;
var crouched_capsule_offset : float;

var lagging_speed_len : float = 0;

@export var is_debugging : bool = false;

var wb_actual_position: Vector3 = Vector3(NAN, NAN, NAN);

@onready var wannabeup_ps = preload("res://chars/wanna_be_up_checker.tscn");
var wannabeup: Area3D;

var climbing_space_available: bool = false;
var ending_position: Vector3;

var state_machine_awaiting: bool = false;

var worldnode: Node;

func spawn_wb_up() -> void:
	# TODO
	# check how wacky it gets. sloped ledges are not for my game I think.
	# just move the top_col_pos manually while shimmying. crazy work.
	ending_position = (climb_casts.top_col_pos
		+ Vector3(0, default_capsule_height/2, 0));
	wannabeup = wannabeup_ps.instantiate();
	wannabeup.global_position = ending_position;
	worldnode.add_child(wannabeup);

func remove_old_wb_ups() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_up_area")):
			print("detected wb_up, rming");
			wn_child.free();

func do_the_top_check() -> void:
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


func there_is_wb() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_ledged_area")):
			print("detected wb, yeah there is");
			return true;
	return false;

func is_wb_below() -> bool:
	return (wb_actual_position.y <= position.y);

func calc_head_z_vector() -> Vector3:
	var res: Vector3 = Vector3(0, 0, 1).rotated(
		Vector3(0, 1, 0),
		head_pc.rotation.y
	);
	return res;

func calc_xz_wall_norm() -> Vector3:
	var res: Vector3 = Vector3(
		climb_casts.hor_col_norm.x,
		0,
		climb_casts.hor_col_norm.z
	).normalized();
	return res;

func along_the_wall_axis() -> Vector3:
	return calc_xz_wall_norm().rotated(Vector3.UP, PI/2.0);

func looking_almost_at_wall_we_are_on() -> bool:
	if (calc_head_z_vector().dot(calc_xz_wall_norm()) > 0.64):
		return true;
	return false;

func remove_old_wb() -> void:
	var wn_children: Array[Node] = worldnode.get_children();
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_ledged_area")):
			print("detected wb, rming");
			wn_child.free();

func space_available() -> bool:
	var wn_children: Array[Node] = worldnode.get_children();
	var wannabe_actual: Area3D = null;
	var succeeded: bool = false;
	for wn_child in wn_children:
		if (wn_child.is_in_group("wannabe_ledged_area")):
			print(wn_child);
			succeeded = true;
			wannabe_actual = wn_child;
			break ;
	if (!succeeded):
		return false;
	wb_actual_position = wannabe_actual.global_position;
	print("set wb actual pos to: ", wb_actual_position);
	await get_tree().physics_frame;
	if (wannabe_actual.has_overlapping_bodies()):
		return false;
	return true;

func _ready() -> void:
	climb_casts.positioned_ledger.connect(do_the_top_check);
	worldnode = get_tree().get_first_node_in_group("worldnode");
	default_head_y = head_pc.position.y;
	lower_head_y = default_head_y - 0.5;
	current_head_y = default_head_y;
	default_capsule_height = collision_shape_3d.shape.height;
	crouched_capsule_height = default_capsule_height * 0.5;
	crouched_capsule_offset = -(default_capsule_height - crouched_capsule_height) / 2.0;
	state_machine.state_changed.connect(_on_state_changed.bind(label_state));
	run_machine.state_changed.connect(_on_state_changed.bind(label_r_state));
	crouch_machine.state_changed.connect(_on_state_changed.bind(label_c_state));
	controllers.me = self;
	state_machine.init(self);
	run_machine.init(self);
	crouch_machine.init(self);

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		head_pc.rotate_y(-event.relative.x * Settings.sensitivity);
		camera_pc.rotate_x(-event.relative.y * Settings.sensitivity);
		camera_pc.rotation.x = clamp(camera_pc.rotation.x, -PI/2, PI/2);
	else:
		state_machine.process_input(event);
		run_machine.process_input(event);
		crouch_machine.process_input(event);

func _physics_process(delta: float) -> void:
	if (!state_machine_awaiting):
		state_machine_awaiting = true;
		await state_machine.process_physics(delta);
		state_machine_awaiting = false;
	run_machine.process_physics(delta);
	crouch_machine.process_physics(delta);

	var horizontal_speed_len: float = Vector2(velocity.x, velocity.z).length();

	camera_pc.fov = (fov_default
		* map_speed_to_fov_multiplier(horizontal_speed_len, delta));
	headbob(horizontal_speed_len, delta);

	if is_debugging:
		label_misc.text = "camera_pc.fov: %5f" % camera_pc.fov;
		label_misc.text += "
	dot: %8.2f
	pos: %8.2f, %8.2f, %8.2f
	tcp: %8.2f, %8.2f, %8.2f
	vel: %8.2f, %8.2f, %8.2f
	spd: %8.2f
	l_d: %8.2f, %8.2f, %8.2f
	speed_modifier        = %8.2f
	crouch_speed_modifier = %8.2f
	is_walking_bc_input   = %s
	ready_to_slide        = %s
	slide_fatigue         = %s
" % [
			calc_head_z_vector().dot(calc_xz_wall_norm()),
			position.x, position.y, position.z,
			climb_casts.top_col_pos.x, climb_casts.top_col_pos.y, climb_casts.top_col_pos.z,
			velocity.x, velocity.y, velocity.z,
			Vector2(velocity.x, velocity.z).length(),
			controllers.last_direction.x,
			controllers.last_direction.y,
			controllers.last_direction.z,
			controllers.speed_modifier,
			controllers.crouch_speed_modifier,
			str(controllers.is_walking_bc_input),
			str(controllers.ready_to_slide),
			str(controllers.slide_fatigue)];

func _process(delta: float) -> void:
	state_machine.process_default(delta);
	run_machine.process_default(delta);
	crouch_machine.process_default(delta);

func map_speed_to_fov_multiplier(
		horizontal_speed_len: float,
		delta: float) -> float:
	lagging_speed_len = lerp(
		lagging_speed_len,
		horizontal_speed_len,
		2*delta);
	return clamp(remap(lagging_speed_len,
			controllers.speed_default * fov_speed_proportion_minimum,
			controllers.speed_default,
			1.0,
			1.1),
		1.0,
		1.1);

## stage 1: stationary. stage 2: movement based on speed.
func headbob(
		horizontal_speed_len: float,
		delta: float) -> void:
	if (horizontal_speed_len <= bob_speed_proportion_minimum
		* controllers.speed_default):
		camera_pc.position.x = lerp(
			camera_pc.position.x,
			0.0,
			5*delta);
		head_pc.position.y = lerp(
			head_pc.position.y,
			current_head_y,
			5*delta);
	else:
		var bob_intensity : float = clamp(remap(horizontal_speed_len,
				controllers.speed_default * bob_speed_proportion_minimum,
				controllers.speed_default,
				1.0,
				1.1),
			1.0,
			1.1);
		if run_machine.current_state == run_state:
			bob_t += 2.5*PI * delta * bob_intensity;
		elif run_machine.current_state == non_run_state:
			bob_t += 2.5*PI * delta * bob_intensity / 2;
		else:
			print("something went catastrophically wrong "
				+ "while determining whether we run or not");
		if bob_t >= 2*PI:
			bob_t = 0;
		camera_pc.position.x = lerp(
			camera_pc.position.x,
			sin(bob_t) / 40 * bob_intensity,
			9*delta);
		head_pc.position.y = lerp(
			head_pc.position.y,
			current_head_y + sin(bob_t * 2) / 20 * bob_intensity,
			9*delta);

func _on_state_changed(state_name: String, label: Label) -> void:
	if (is_debugging):
		label.set_text(state_name);

func check_above_for_uncrouching() -> bool:
	above_raycast.force_raycast_update();
	if above_raycast.is_colliding():
		return false;
	return true;
