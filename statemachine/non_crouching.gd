extends State

@export var controllers: Node

@export var crouching: State

func enter() -> void:
	controllers.ready_to_slide = true;
	controllers.crouch_speed_modifier = 1;
	super();
	actor.collision_shape_3d.shape.height = actor.default_capsule_height;
	actor.collision_shape_3d.position.y = 0;
	actor.current_head_y = actor.default_head_y;


func process_default(delta: float) -> State:
	if Input.is_action_just_pressed("crouch"):
		return crouching;
	return null;
