extends State

@export var controllers: Node

@export var run: State

func enter() -> void:
	controllers.speed_modifier = Settings.nonrun_modifier;
	super();

func process_default(delta: float) -> State:
	if Input.is_action_just_pressed("run"):
		return run;
	return null;
