extends State

@export var controllers: Node

@export var non_crouching: State

func enter() -> void:
	controllers.crouch_speed_modifier = 0.3;
	super();
	actor.collision_shape_3d.scale.y = 0.5;
	actor.collision_shape_3d.position.y = -0.5;
	actor.current_head_y = actor.lower_head_y;


func process_default(delta: float) -> State:
	if (Input.is_action_just_pressed("crouch")
		and actor.check_above_for_uncrouching()):
		return non_crouching;
	return null;
