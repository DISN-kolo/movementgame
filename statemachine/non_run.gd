extends RunningState

@export var controllers: Node

@export var run: RunningState

func enter() -> void:
	controllers.speed_modifier = nonrun_modifier;
	super();

func process_default(delta: float) -> RunningState:
	if Input.is_action_just_pressed("run"):
		return run;
	return null;
