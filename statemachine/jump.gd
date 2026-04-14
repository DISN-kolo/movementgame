extends State

@export var controllers: Node

@export var fall_state: State
@export var walk_state: State
@export var idle_state: State
@export var transitional_to_ledged_state: State
@export var animated_vault_state: State

var jump_velocity: float = 10;

func enter() -> void:
	actor.climb_casts.is_hopping = false;
	actor.velocity.y = jump_velocity;
	super();

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);

#func process_input(event: InputEvent) -> State:
	#if Input.is_action_pressed("jump"):
		#actor.climb_casts.calc_horizontal_coll_point();
	#return null;

func process_physics(delta: float) -> State:
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	if (Input.is_action_pressed("jump")):
		print("J START");
		actor.remove_old_wb();
		print("J RMD WB");
		actor.climb_casts.calc_horizontal_coll_point();
		print("J CALCD H COLL POINT");
		if (actor.there_is_wb()):
			print("J THERE IS WB");
			if (actor.space_available()):
				print("determined space available from jump");
				return transitional_to_ledged_state;
			elif (actor.is_wb_below() && actor.climbing_space_available):
				print("determined vault from jump");
				return animated_vault_state;
			print("J NO SPACE NO VAULT");
		print("J WB-IF ENDED");
	if (input_dir.length() > 0.1):
		controllers.is_walking_bc_input = true;
		direction = (actor.head_pc.transform.basis
			* Vector3(input_dir.x, 0, input_dir.y));
		controllers.last_direction = direction;
		var temp_fullmultiplier: Vector3 = (direction
			* controllers.speed_default
			* controllers.speed_modifier
			* controllers.crouch_speed_modifier
			* delta);
		actor.velocity.x = lerp(actor.velocity.x,
			temp_fullmultiplier.x, 3*delta);
		actor.velocity.z = lerp(actor.velocity.z,
			temp_fullmultiplier.z, 3*delta);
	else:
		controllers.is_walking_bc_input = false;
	
	actor.velocity.y -= Settings.gravity;
	actor.move_and_slide();
	
	if (!actor.is_on_floor() and actor.velocity.y < 0):
		return fall_state;
	if (actor.is_on_floor()):
		if (input_dir.length() > 0.1):
			return walk_state;
		return idle_state;
	return null;
