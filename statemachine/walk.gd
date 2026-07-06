class_name Walk
extends State

@export var controllers: Node

@export var fall_state: State
@export var jump_state: State
@export var idle_state: State
@export var slide_state: State
@export var low_vault_state: State

func enter() -> void:
	actor.climb_casts.is_hopping = false;
	controllers.is_walking_bc_input = true;
	super();

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

func process_input(event: InputEvent) -> State:
	if (Input.is_action_just_pressed("jump") and actor.is_on_floor()):
		actor.low_vault_casts.completely_prepare_stepup();
		if (actor.low_vault_casts.there_is_wb_lvu()):
			print("yup, there is wb lvu. run the first phase check");
			actor.low_vault_casts.run_and_save_first_classify();
			await actor.low_vault_casts.calculate_area_overlap();
			print("after await, the results are in:");
			print("lvu overlap? ", actor.low_vault_casts.lvu_overlaps);
			# FIXME always gets false. wtf ^^^^^^^^^^^^^^^^^^^^^^^^^^
			if (!actor.low_vault_casts.lvu_overlaps):
				print("no lvu overlap, run the check 2");
				actor.low_vault_casts.run_and_save_second_classify();
		actor.character_audio.play_next_fast_step();
		return jump_state;
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
	controllers.hor_vel_processor(direction, delta, 8);
	controllers.fall_vel_processor(delta);
	actor.move_and_slide();
	
	if (!actor.is_on_floor()):
		return fall_state;
	if (input_dir.length() < 0.1):
		return idle_state;
	return null;
