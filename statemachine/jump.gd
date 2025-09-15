extends State

@export var controllers: Node

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
	
	if input_dir.length() > 0.1:
		controllers.is_walking_bc_input = true;
		direction = (actor.head_pc.transform.basis
			* Vector3(input_dir.x, 0, input_dir.y));
		var temp_fullmultiplier: Vector3 = (direction
			* controllers.speed_default
			* controllers.speed_modifier * delta);
		actor.velocity.x = lerp(actor.velocity.x,
			temp_fullmultiplier.x, 3*delta);
		actor.velocity.z = lerp(actor.velocity.z,
			temp_fullmultiplier.z, 3*delta);
	else:
		controllers.is_walking_bc_input = false;
	
	actor.velocity.y -= gravity;
	actor.move_and_slide();
	
	if !actor.is_on_floor() and actor.velocity.y < 0:
		return fall_state;
	if actor.is_on_floor():
		if input_dir.length() > 0.1:
			return walk_state;
		return idle_state;
	return null;
