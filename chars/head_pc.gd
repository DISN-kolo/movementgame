extends Node3D;
class_name HeadPC;

var lagging_speed_len : float = 0;

var fov_default : float = 85;
var fov_speed_proportion_minimum : float = 0.1;
var bob_speed_proportion_minimum : float = 0.2;
var bob_t : float = 0;
var half_bob_step : bool = true;
signal bobbed;

var slow_step_speed_proportion : float = 0.5;
var traveled_for_step : float = 0;
var step_distance : float = 1.5;

@onready var camera_pc: Camera3D = %CameraPC;
var pc: Player;

var run_machine: StateMachine;
var run_state: Run;
var non_run_state: NonRun;

func handle_event(event) -> void:
	rotate_y(-event.relative.x * Settings.sensitivity);
	camera_pc.rotate_x(-event.relative.y * Settings.sensitivity);
	camera_pc.rotation.x = clamp(camera_pc.rotation.x, -PI/2, PI/2);

func _ready() -> void:
	bobbed.connect(do_a_step_on_bob);

func process_physics_tick(delta: float, hsl: float) -> void:
	camera_pc.fov = (fov_default
		* map_speed_to_fov_multiplier(hsl, delta));
	headbob(hsl, delta);

func map_speed_to_fov_multiplier(
		horizontal_speed_len: float,
		delta: float) -> float:
	lagging_speed_len = lerp(
		lagging_speed_len,
		horizontal_speed_len,
		2*delta);
	return clamp(remap(lagging_speed_len,
			pc.controllers.speed_default * fov_speed_proportion_minimum,
			pc.controllers.speed_default,
			1.0,
			1.1),
		1.0,
		1.1);

## stage 1: stationary. stage 2: movement based on speed.
func headbob(
		horizontal_speed_len: float,
		delta: float) -> void:
	if (horizontal_speed_len <= bob_speed_proportion_minimum
		* pc.controllers.speed_default):
		camera_pc.position.x = lerp(
			camera_pc.position.x,
			0.0,
			5*delta);
		position.y = lerp(
			position.y,
			pc.current_head_y,
			5*delta);
	else:
		var bob_intensity : float = clamp(remap(horizontal_speed_len,
				pc.controllers.speed_default * bob_speed_proportion_minimum,
				pc.controllers.speed_default,
				1.0,
				1.1),
			1.0,
			1.1);
		if (run_machine.current_state == run_state):
			bob_t += 2.5*PI * delta * bob_intensity;
		elif (run_machine.current_state == non_run_state):
			bob_t += 2.5*PI * delta * bob_intensity / 2;
		else:
			print("something went catastrophically wrong "
				+ "while determining whether we run or not");
		if (bob_t >= 2*PI):
			bob_t = 0;
			half_bob_step = true;
			bobbed.emit(horizontal_speed_len);
		if ((bob_t >= PI) and half_bob_step):
			bobbed.emit(horizontal_speed_len);
			half_bob_step = false;
		camera_pc.position.x = lerp(
			camera_pc.position.x,
			sin(bob_t) / 40 * bob_intensity,
			9*delta);
		position.y = lerp(
			position.y,
			pc.current_head_y + sin(bob_t * 2) / 20 * bob_intensity,
			9*delta);

func do_a_step_on_bob(hsl: float) -> void:
	if (!pc.is_on_floor()):
		return ;
	if (hsl <= pc.controllers.speed_default * slow_step_speed_proportion):
		pc.character_audio.play_next_slow_step();
	else:
		pc.character_audio.play_next_fast_step();
