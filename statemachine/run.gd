extends RunningState

@export var controllers: Node

@export var non_run: RunningState

func enter() -> void:
	controllers.speed_modifier = 1;
	super();

func process_input(event: InputEvent) -> RunningState:
	if Input.is_action_just_pressed("run"):
		return non_run;
	return null;
