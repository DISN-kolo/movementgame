extends State

@export var controllers: Node

@export var fall_state: State = null;
@export var jump_state: State = null;
@export var animated_climb_state: State = null;
@export var shimmy_ledge_state: State = null;
@export var hop_up_from_ledge_state: State = null;

var init_delay_passed: bool = false;

func enter() -> void:
	actor.climb_casts.is_hopping = false;
	actor.climb_casts.hopped_from_rid = actor.climb_casts.latest_rid;
	print("just set rid to ", actor.climb_casts.hopped_from_rid);
	$"../../AutoclimbDelay".start();
	init_delay_passed = false;
	controllers.is_walking_bc_input = false;
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
	actor.velocity = Vector3(0.0, 0.0, 0.0);
	if (Input.is_action_pressed("jump")):
		if (actor.looking_almost_at_wall_we_are_on() and init_delay_passed and actor.climbing_space_available):
			init_delay_passed = false;
			return animated_climb_state;
	if (abs(Input.get_vector("mov_left", "mov_right",
		"mov_up", "mov_down").x) >= 0.01):
		return shimmy_ledge_state;
	return null;


func _on_autoclimb_delay_timeout() -> void:
	init_delay_passed = true;
