extends State

@export var controllers: Node

@export var fall_state: State
@export var jump_state: State
@export var idle_state: State
@export var walk_state: State

## don't forget to multiply by delta
var starting_temp_fullmultiplier: Vector3 = Vector3(0, 0, 0);
var finishing_temp_fullmultiplier: Vector3 = Vector3(0, 0, 0);

func enter() -> void:
	super();
	controllers.ready_to_slide = false;
	controllers.start_fatigue_timer();
	# delta accounted for
	starting_temp_fullmultiplier = (
		controllers.last_direction
		* Vector2(actor.velocity.x, actor.velocity.z).length()
		* controllers.speed_modifier
		* controllers.slide_modifier);
	print("stf: ", starting_temp_fullmultiplier);
	actor.velocity.x = starting_temp_fullmultiplier.x;
	actor.velocity.z = starting_temp_fullmultiplier.z;
	finishing_temp_fullmultiplier = (
		starting_temp_fullmultiplier
		/ controllers.slide_modifier
		* controllers.slide_post_modifier);

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed("jump") and actor.is_on_floor():
		return jump_state;
	if Input.is_action_just_pressed("crouch"):
		return walk_state;
	return null

func process_physics(delta: float) -> State:
	# this is so dumb but idk what do I do about it.
	actor.velocity.x = lerp(
		actor.velocity.x,
		finishing_temp_fullmultiplier.x,
		2*delta);
	actor.velocity.z = lerp(
		actor.velocity.z,
		finishing_temp_fullmultiplier.z,
		2*delta);
	actor.velocity.y -= Settings.gravity;
	actor.move_and_slide();
	
	if !actor.is_on_floor() and actor.velocity.y < 0:
		return fall_state;
	if (Vector2(
			actor.velocity.x,
			actor.velocity.z).length() <= (
				controllers.speed_default
				* delta
				* controllers.slide_post_modifier * 1.1)):
		return idle_state;
	return null;
