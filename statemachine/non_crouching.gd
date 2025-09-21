extends CrouchState

@export var controllers: Node

@export var crouching: CrouchState

func enter() -> void:
	#controllers.speed_modifier = nonrun_modifier;
	super();

func process_default(delta: float) -> CrouchState:
	if Input.is_action_just_pressed("crouch"):
		return crouching;
	return null;
