extends RunningState

@export var controllers: Node

@export var non_run: RunningState

func enter() -> void:
	actor.fov_pc = 90;
	controllers.speed_modifier = sprint_modifier;
	super();

func process_input(event: InputEvent) -> RunningState:
	if Input.is_action_just_pressed("run"):
		return non_run;
	#print(velocity);
	#move_and_slide();
	return null;

func process_physics(delta: float) -> RunningState:
	if controllers.is_walking_bc_input == false:
		return non_run;
	if actor.camera_pc.fov != actor.fov_pc:
		actor.camera_pc.fov += (actor.fov_pc - actor.camera_pc.fov) * delta * 8;
	return null;
