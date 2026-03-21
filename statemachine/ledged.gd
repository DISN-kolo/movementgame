extends State

@export var controllers: Node

@export var fall_state: State
@export var jump_state: State
@export var animated_climb_state: State
@export var shimmy_ledge_state: State

func enter() -> void:
	controllers.is_walking_bc_input = false;
	super();

func process_input(event: InputEvent) -> State:
	# TODO return ledged state
	# in the ledged state you should wait for inputs and then either enter
	# the climb "animated state" (similar to slide) or the falling state
	if (Input.is_action_just_pressed("jump")):
		if (actor.looking_almost_at_wall_we_are_on()):
			return animated_climb_state;
		else:
			return jump_state;
	if (Input.is_action_just_pressed("mov_up")):
		if (actor.looking_almost_at_wall_we_are_on()):
			return animated_climb_state;
	if (Input.is_action_just_pressed("mov_down")):
		if (actor.looking_almost_at_wall_we_are_on()):
			return fall_state;
	if (Input.is_action_just_pressed("crouch")):
		return fall_state;
	return null

func process_physics(delta: float) -> State:
	if (abs(Input.get_vector("mov_left", "mov_right",
		"mov_up", "mov_down").x) >= 0.01):
		return shimmy_ledge_state;

	return null;
