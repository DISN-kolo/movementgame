extends State

@export var controllers: Node;

@export var non_crouching: State;

var really_need_uncrouching: bool = false;

func _ready() -> void:
	Signals.get_uncrouched.connect(on_get_uncrouched);

func enter() -> void:
	controllers.crouch_speed_modifier = 0.3;
	super();
	actor.collision_shape_3d.shape.height = actor.crouched_capsule_height;
	actor.collision_shape_3d.position.y = actor.crouched_capsule_offset;
	actor.current_head_y = actor.lower_head_y;

func process_default(delta: float) -> State:
	if ((Input.is_action_just_pressed("crouch")
			and actor.check_above_for_uncrouching())
			or really_need_uncrouching):
		really_need_uncrouching = false;
		return non_crouching;
	return null;

func on_get_uncrouched() -> void:
	really_need_uncrouching = true;
