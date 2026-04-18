class_name Fall
extends State

@export var controllers: Node

@export var jump_state: State
@export var walk_state: State
@export var idle_state: State
@export var transitional_to_ledged_state: State
@export var animated_vault_state: State

func enter() -> void:
	actor.climb_casts.is_hopping = false;
	super();

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

#func process_input(event: InputEvent) -> State:
	#return null;

# TODO: add pre-fall for coyote time. steal from the GJ project

func process_physics(delta: float) -> State:
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	if (Input.is_action_pressed("jump")):
		actor.remove_old_wb();
		actor.climb_casts.completely_prepare_ledging();
		if (actor.there_is_wb()):
			if (await actor.space_available()):
				print("determined space available from fall");
				return transitional_to_ledged_state;
			elif (actor.is_wb_below() && actor.climbing_space_available):
				print("determined vault from fall");
				return animated_vault_state;
	if (input_dir.length() > 0.1):
		controllers.is_walking_bc_input = true;
		direction = (actor.head_pc.transform.basis
			* Vector3(input_dir.x, 0, input_dir.y));
		controllers.last_direction = direction;
		controllers.hor_vel_processor(direction, delta, 1);
	else:
		controllers.is_walking_bc_input = false;

	controllers.fall_vel_processor(delta);
	actor.move_and_slide();
	
	if (actor.is_on_floor()):
		if (input_dir.length() > 0.1):
			return walk_state;
		return idle_state;
	return null;
