extends State

@export var controllers: Node

@export var fall_state: State = null;
@export var jump_state: State = null;
@export var animated_climb_state: State = null;
@export var ledged_state: State = null;
@export var hop_up_from_ledge_state: State = null;

var input_dir: Vector2 = Vector2.ZERO;
var direction: Vector3 = Vector3.ZERO;
var difference_to_wbu: Vector3 = Vector3.ZERO;
var difference_to_tcp: Vector3 = Vector3.ZERO;

func enter() -> void:
	difference_to_wbu = Globals.current_wbu_pos - actor.global_position;
	difference_to_tcp = actor.climb_casts.top_col_pos - actor.global_position;
	actor.velocity = Vector3(0, 0, 0);
	actor.climb_casts.is_hopping = false;
	#controllers.is_walking_bc_input = true;
	super();

func process_input(event: InputEvent) -> State:
	if (Input.is_action_just_pressed("jump")):
		actor.do_the_top_check();
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
		actor.do_the_top_check();
		if (actor.looking_almost_at_wall_we_are_on() and actor.climbing_space_available):
			return animated_climb_state;
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	direction = (
		actor.head_pc.transform.basis
		* Vector3(input_dir.x, 0, input_dir.y));
	# TODO slowdown modifier for ts
	# TODO check for edge of wall. how? shoot rays in front of us...
	# TODO move the ending position of the climb. Well, recalc it, in fact.
	direction = direction.project(actor.along_the_wall_axis());
	controllers.last_direction = direction;
	controllers.hor_vel_processor(direction, delta, 8);
	actor.move_and_slide();
	
	Signals.move_wanna_be_up.emit(difference_to_wbu + actor.global_position);
	Signals.move_top_col_pos.emit(difference_to_tcp + actor.global_position);
	if (input_dir.length() < 0.1):
		actor.do_the_top_check();
		return ledged_state;
	return null;
