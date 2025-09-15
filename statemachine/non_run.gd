extends RunningState

@export var controllers: Node

@export var run: RunningState

func enter() -> void:
	actor.fov_pc = actor.fov_default;
	controllers.speed_modifier = 1.0;
	super();

func process_input(event: InputEvent) -> RunningState:
	if Input.is_action_just_pressed("run") and controllers.is_walking_bc_input:
		return run;
	#print(velocity);
	#move_and_slide();
	return null;

func process_physics(delta: float) -> RunningState:
	if actor.camera_pc.fov != actor.fov_pc:
		actor.camera_pc.fov += (actor.fov_pc - actor.camera_pc.fov) * delta * 8;
	return null;
