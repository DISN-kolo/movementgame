extends State

@export var controllers: Node

@export var non_run: State

func enter() -> void:
	controllers.speed_modifier = 1;
	super();

func process_default(delta: float) -> State:
	if Input.is_action_just_pressed("run"):
		return non_run;
	return null;
