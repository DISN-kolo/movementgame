extends CharacterBody3D;

@onready var head_pc: Node3D = $HeadPC;
@onready var camera_pc: Camera3D = $HeadPC/CameraPC;
@onready var label_state: Label = $LabelState;
@onready var label_r_state: Label = $LabelRState;
@onready var label_misc: Label = $LabelMisc;

@onready var controllers: Node = $Controllers;

@onready var state_machine: Node = $Controllers/StateMachine;
@onready var run_machine: Node = $Controllers/RunMachine;

var fov_default : float = 85;
#var fov_pc : float = fov_default;
var fov_speed_proportion_minimum : float = 0.1;

var lagging_speed_len : float = 0;

@export var is_debugging : bool = false;
func _ready() -> void:
	state_machine.init(self);
	run_machine.init(self);

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

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta);
	run_machine.process_physics(delta);

	camera_pc.fov = fov_default * map_speed_to_fov_multiplier(velocity, delta);

	if is_debugging:
		label_misc.text = "camera_pc.fov: %5f" % camera_pc.fov;
		label_misc.text += "
	pos: %8.2f, %8.2f, %8.2f
	vel: %8.2f, %8.2f, %8.2f" % [
			position.x, position.y, position.z,
			velocity.x, velocity.y, velocity.z];

func _process(delta: float) -> void:
	state_machine.process_default(delta);
	run_machine.process_default(delta);

func map_speed_to_fov_multiplier(speed_rn: Vector3, delta: float) -> float:
	var horizontal_speed: Vector2 = Vector2(speed_rn.x, speed_rn.z) / delta;
	var horizontal_speed_len: float = horizontal_speed.length();
	lagging_speed_len = lerp(
		lagging_speed_len,
		horizontal_speed_len,
		2*delta);
	return clamp(remap(lagging_speed_len,
			controllers.speed_default * fov_speed_proportion_minimum,
			controllers.speed_default,
			1.0,
			1.05),
		1.0,
		1.05);
