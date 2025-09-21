extends CrouchState

@export var controllers: Node

@export var crouching: CrouchState

func enter() -> void:
	controllers.ready_to_slide = true;
	controllers.crouch_speed_modifier = 1;
	super();
	actor.collision_shape_3d.scale.y = 1;
	actor.collision_shape_3d.position.y = 0;
	actor.current_head_y = actor.default_head_y;
	#controllers.speed_modifier = nonrun_modifier;


func process_default(delta: float) -> CrouchState:
	if Input.is_action_just_pressed("crouch"):
		return crouching;
	return null;
