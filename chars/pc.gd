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
@onready var run_state: Run = $Controllers/RunMachine/Run;
@onready var non_run_state: NonRun = $Controllers/RunMachine/NonRun;
@onready var crouch_machine: StateMachine = $Controllers/CrouchMachine;

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D;
@onready var head_casts: HeadCasts = %HeadCasts;
@onready var climb_casts: ClimbCastsNode = %ClimbCasts;
@onready var hand_casts: HandCasts = %HandCasts;
@onready var low_vault_casts: LowVaultCastsNode = %LowVaultCasts;

@onready var character_audio: Node3D = %CharacterAudio;

# related to crouching
var default_head_y : float;
var lower_head_y : float;
var current_head_y : float;
var default_capsule_height : float;
var default_capsule_radius : float;
var crouched_capsule_height : float;
var crouched_capsule_offset : float;

@export var is_debugging : bool = false;

var state_machine_awaiting: bool = false;

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


func _ready() -> void:
	default_head_y = head_pc.position.y;
	lower_head_y = default_head_y - 0.5;
	current_head_y = default_head_y;
	default_capsule_height = collision_shape_3d.shape.height;
	default_capsule_radius = collision_shape_3d.shape.radius;
	crouched_capsule_height = default_capsule_height * 0.5;
	crouched_capsule_offset = -(default_capsule_height - crouched_capsule_height) / 2.0;
	state_machine.state_changed.connect(_on_state_changed.bind(label_state));
	run_machine.state_changed.connect(_on_state_changed.bind(label_r_state));
	crouch_machine.state_changed.connect(_on_state_changed.bind(label_c_state));
	controllers.me = self;
	head_pc.pc = self;
	head_pc.run_machine = run_machine;
	head_pc.run_state = run_state;
	head_pc.non_run_state = non_run_state;
	head_casts.pc = self;
	climb_casts.pc = self;
	climb_casts.collision_shape_3d = collision_shape_3d;
	low_vault_casts.pc = self;
	state_machine.init(self);
	run_machine.init(self);
	crouch_machine.init(self);

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		head_pc.handle_event(event);
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

	head_pc.process_physics_tick(delta, horizontal_speed_len);

	if is_debugging:
		label_misc.text = "camera_pc.fov: %5f" % camera_pc.fov;
		label_misc.text += "
	pos: %8.2f, %8.2f, %8.2f
	tcp: %8.2f, %8.2f, %8.2f
	vel: %8.2f, %8.2f, %8.2f
	spd: %8.2f
	speed_modifier        = %8.2f
	crouch_speed_modifier = %8.2f
	is_walking_bc_input   = %s
	low vault result: %8.2f, %8.2f, %8.2f
	first condition returns: %s
	second condition returns: %s
" % [
			position.x, position.y, position.z,
			climb_casts.top_col_pos.x, climb_casts.top_col_pos.y, climb_casts.top_col_pos.z,
			velocity.x, velocity.y, velocity.z,
			Vector2(velocity.x, velocity.z).length(),
			controllers.speed_modifier,
			controllers.crouch_speed_modifier,
			str(controllers.is_walking_bc_input),
			low_vault_casts.top_col_pos.x,
			low_vault_casts.top_col_pos.y,
			low_vault_casts.top_col_pos.z,
			low_vault_casts.FirstPartCondition.keys()[low_vault_casts.saved_fp_condition],
			low_vault_casts.SecondPartCondition.keys()[low_vault_casts.saved_sp_condition],
	];

func _process(delta: float) -> void:
	state_machine.process_default(delta);
	run_machine.process_default(delta);
	crouch_machine.process_default(delta);

func _on_state_changed(state_name: String, label: Label) -> void:
	if (is_debugging):
		label.set_text(state_name);

func check_above_for_uncrouching() -> bool:
	above_raycast.force_raycast_update();
	if above_raycast.is_colliding():
		return false;
	return true;
