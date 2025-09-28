extends CharacterBody3D;

@onready var above_raycast: RayCast3D = $AboveRaycast

@onready var head_pc: Node3D = $HeadPC;
@onready var camera_pc: Camera3D = $HeadPC/CameraPC;
@onready var label_state: Label = $MainControl/LabelState;
@onready var label_r_state: Label = $MainControl/LabelRState;
@onready var label_c_state: Label = $MainControl/LabelCState;
@onready var label_misc: Label = $MainControl/LabelMisc;

@onready var controllers: Node = $Controllers;

@onready var state_machine: Node = $Controllers/StateMachine;
@onready var run_machine: Node = $Controllers/RunMachine;

@onready var run_state: RunningState = $Controllers/RunMachine/Run;
@onready var non_run_state: RunningState = $Controllers/RunMachine/NonRun;

@onready var crouch_machine: CrouchMachine = $Controllers/CrouchMachine;

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D;

var fov_default : float = 85;
var fov_speed_proportion_minimum : float = 0.1;
var bob_speed_proportion_minimum : float = 0.2;
var bob_t : float = 0;

# related to crouching
var default_head_y : float;
var lower_head_y : float;
var current_head_y : float;

var lagging_speed_len : float = 0;

@export var is_debugging : bool = false;
func _ready() -> void:
	default_head_y = head_pc.position.y;
	lower_head_y = default_head_y - 0.5;
	current_head_y = default_head_y;
	state_machine.init(self);
	run_machine.init(self);
	crouch_machine.init(self);

func _unhandled_input(event) -> void:
	# if it's gonna come to making sure camera does this and that while we're
	#in some state, or like the mouse movement shall affect some bs, then
	#we'd need to redirect even this thing to the state machine. but it'll be
	#a problem for later, if it even shows up lol. we'll see
	if event is InputEventMouseMotion:
		head_pc.rotate_y(-event.relative.x * Settings.sensitivity);
		camera_pc.rotate_x(-event.relative.y * Settings.sensitivity);
		camera_pc.rotation.x = clamp(camera_pc.rotation.x, -PI/2, PI/2);
	else:
		state_machine.process_input(event);
		run_machine.process_input(event);
		crouch_machine.process_input(event);

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta);
	run_machine.process_physics(delta);
	crouch_machine.process_physics(delta);

	var horizontal_speed_len: float = (Vector2(velocity.x, velocity.z).length()
		/ delta);

	camera_pc.fov = (fov_default
		* map_speed_to_fov_multiplier(horizontal_speed_len, delta));
	headbob(horizontal_speed_len, delta);

	if is_debugging:
		label_misc.text = "camera_pc.fov: %5f" % camera_pc.fov;
		label_misc.text += "
	pos: %8.2f, %8.2f, %8.2f
	vel: %8.2f, %8.2f, %8.2f
	spd: %8.2f
	l_d: %8.2f, %8.2f, %8.2f
	speed_modifier        = %8.2f
	crouch_speed_modifier = %8.2f
	is_walking_bc_input   = %s
	ready_to_slide        = %s
	slide_fatigue         = %s
" % [
			position.x, position.y, position.z,
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

func check_above_for_uncrouching() -> bool:
	above_raycast.force_raycast_update();
	if above_raycast.is_colliding():
		return false;
	return true;
