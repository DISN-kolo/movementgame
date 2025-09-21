extends CrouchState

@export var controllers: Node

@export var non_crouching: CrouchState

func enter() -> void:
	super();
	actor.collision_shape_3d.scale.y = 0.5;
	actor.collision_shape_3d.position.y = -0.5;
	actor.current_head_y = actor.lower_head_y;
	#controllers.speed_modifier = nonrun_modifier;


func process_default(delta: float) -> CrouchState:
	if Input.is_action_just_pressed("crouch"):
		return non_crouching;
	return null;
