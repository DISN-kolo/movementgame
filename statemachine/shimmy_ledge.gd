extends State

@export var controllers: Node

@export var fall_state: State = null;
@export var jump_state: State = null;
@export var animated_climb_state: State = null;
@export var ledged_state: State = null;
@export var hop_up_from_ledge_state: State = null;

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

func enter() -> void:
	actor.velocity = Vector3(0, 0, 0);
	actor.climb_casts.is_hopping = false;
	#controllers.is_walking_bc_input = true;
	super();

func process_input(event: InputEvent) -> State:
	if (Input.is_action_just_pressed("jump")):
		if (actor.looking_almost_at_wall_we_are_on()):
			if (actor.climbing_space_available):
				return animated_climb_state;
			else:
				return hop_up_from_ledge_state;
		else:
			return jump_state;
	if (Input.is_action_just_pressed("mov_down")):
		if (actor.looking_almost_at_wall_we_are_on()):
			return fall_state;
	if (Input.is_action_just_pressed("crouch")):
		return fall_state;
	return null

func process_physics(delta: float) -> State:
	if (Input.is_action_pressed("jump")):
		if (actor.looking_almost_at_wall_we_are_on() and actor.climbing_space_available):
			return animated_climb_state;
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	direction = (
		actor.head_pc.transform.basis
		* Vector3(input_dir.x, 0, input_dir.y));
	# TODO vector math to determine direction perpendicular to the wall segment you're on!
	# that is to say, Vector3.project :)
	controllers.last_direction = direction;
	controllers.hor_vel_processor(direction, delta, 8);
	actor.move_and_slide();
	if (input_dir.length() < 0.1):
		return ledged_state;
	return null;
