extends CharacterBody3D;

@onready var head_pc: Node3D = $HeadPC;
@onready var camera_pc: Camera3D = $HeadPC/CameraPC;
@onready var label_state: Label = $LabelState
@onready var label_misc: Label = $LabelMisc

@onready var state_machine: Node = $Controllers/StateMachine;

func _ready() -> void:
	state_machine.init(self);

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

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta);
	label_misc.text = "
	%8.2f, %8.2f, %8.2f
	\n%8.2f, %8.2f, %8.2f" % [
		position.x, position.y, position.z,
		velocity.x, velocity.y, velocity.z];
	# I need to find a monospace font :)

func _process(delta: float) -> void:
	state_machine.process_default(delta);
