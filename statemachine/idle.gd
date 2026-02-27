extends State

@export var controllers: Node

@export var fall_state: State
@export var jump_state: State
@export var walk_state: State

func enter() -> void:
	controllers.is_walking_bc_input = false;
	super();

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed("jump") and actor.is_on_floor():
		return jump_state;
	return null

func process_physics(delta: float) -> State:
	if (Input.get_vector("mov_left", "mov_right",
		"mov_up", "mov_down").length() >= 0.01):
		return walk_state;
	if actor.is_on_floor():
		actor.velocity.x = lerp(actor.velocity.x, 0.0, 9*delta);
		actor.velocity.z = lerp(actor.velocity.z, 0.0, 9*delta);
	actor.velocity.y -= Settings.gravity;
	actor.move_and_slide();
	
	if !actor.is_on_floor():
		return fall_state;
	return null;
