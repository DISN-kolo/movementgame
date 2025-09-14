extends State

@export var fall_state: State
@export var walk_state: State
@export var idle_state: State

var jump_velocity: float = 10;

func enter() -> void:
	actor.velocity.y = jump_velocity;
	super();

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

func process_physics(delta: float) -> State:
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	direction = (actor.head_pc.transform.basis * Vector3(input_dir.x, 0, input_dir.y));
	var temp_fullmultiplier = direction * speed_modifier * delta;
	actor.velocity += temp_fullmultiplier * air_speed_modifier;
	var temp_y = actor.velocity.y;
	actor.velocity.y = 0;
	actor.velocity = actor.velocity.normalized() * temp_fullmultiplier.length();
	actor.velocity.y = temp_y;
	actor.velocity.y -= gravity;
	actor.move_and_slide();
	
	if !actor.is_on_floor() and actor.velocity.y < 0:
		return fall_state;
	if actor.is_on_floor():
		if input_dir.length() > 0.1:
			return walk_state;
		return idle_state;
	return null;
