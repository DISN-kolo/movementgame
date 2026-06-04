class_name Idle
extends State

@export var controllers: Node

@export var fall_state: State
@export var jump_state: State
@export var walk_state: State
@export var transitional_to_ledged_state: State
@export var animated_vault_state: State

func enter() -> void:
	actor.climb_casts.is_hopping = false;
	controllers.is_walking_bc_input = false;
	super();

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed("jump") and actor.is_on_floor():
		# TODO see to using a signal here maybe as well (just like with landing)
		actor.character_audio.play_next_fast_step();
		return jump_state;
	return null

func process_physics(delta: float) -> State:
	if (Input.is_action_pressed("jump")):
		actor.climb_casts.remove_old_wb_ledged();
		actor.climb_casts.completely_prepare_ledging();
		if (actor.climb_casts.there_is_wb_ledged()):
			if (await actor.climb_casts.ledging_space_available()):
				print("determined space available from idle");
				return transitional_to_ledged_state;
			elif (actor.climb_casts.is_wb_ledged_below() && actor.climb_casts.climbing_space_available):
				print("determined vault from idle");
				return animated_vault_state;
		actor.low_vault_casts.rm_old_wb_lvus();
		actor.low_vault_casts.completely_prepare_stepup();
		if (await actor.low_vault_casts.stepup_space_available()):
			print("determined stepup available");
	if (Input.get_vector("mov_left", "mov_right",
		"mov_up", "mov_down").length() >= 0.01):
		return walk_state;
	if (actor.is_on_floor()):
		controllers.hor_vel_processor(Vector3.ZERO, delta, 9);
	controllers.fall_vel_processor(delta);
	actor.move_and_slide();

	if (!actor.is_on_floor()):
		return fall_state;
	return null;
