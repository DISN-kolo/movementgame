extends State

@export var controllers: Node

@export var fall_state: State
@export var jump_state: State
@export var idle_state: State
@export var slide_state: State

func enter() -> void:
	controllers.is_walking_bc_input = true;
	super();

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

func process_input(event: InputEvent) -> State:
	#print(event);
	if Input.is_action_just_pressed("jump") and actor.is_on_floor():
		return jump_state;
	#print(velocity);
	#move_and_slide();
	return null

func process_physics(delta: float) -> State:
	if (controllers.ready_to_slide
		and !(controllers.slide_fatigue)
		and controllers.is_walking_bc_input
		and Input.is_action_just_pressed("crouch")
		and actor.is_on_floor()):
		return slide_state;
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	direction = (
		actor.head_pc.transform.basis
		* Vector3(input_dir.x, 0, input_dir.y));
	controllers.last_direction = direction;
	var temp_fullmultiplier: Vector3 = (
		direction
		* controllers.speed_default
		* controllers.speed_modifier
		* controllers.crouch_speed_modifier
		* delta);
	actor.velocity.x = lerp(
		actor.velocity.x,
		temp_fullmultiplier.x,
		8*delta);
	actor.velocity.z = lerp(
		actor.velocity.z,
		temp_fullmultiplier.z,
		8*delta);
	actor.velocity.y -= Settings.gravity;
	actor.move_and_slide();
	
	if !actor.is_on_floor():
		return fall_state;
	if input_dir.length() < 0.1:
		return idle_state;
	return null;
