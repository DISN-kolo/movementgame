extends Node
class_name Controllers;

@onready var crouch_fatigue_timer: Timer = $CrouchFatigueTimer

var me: Player;

var speed_default: float = 12.0;
var speed_modifier: float = 1.0;
var crouch_speed_modifier: float = 1.0;
var slide_modifier: float = 1.5;
var slide_post_modifier: float = 0.7;
var last_direction: Vector3 = Vector3(0, 0, 0);

var is_walking_bc_input: bool = false;

var ready_to_slide: bool = false;
var slide_fatigue: bool = false;

func _on_crouch_fatigue_timer_timeout() -> void:
	slide_fatigue = false;

func start_fatigue_timer() -> void:
	slide_fatigue = true;
	crouch_fatigue_timer.start();

func hor_vel_processor(direction: Vector3, delta: float, accel_factor: float) -> void:
	var target: Vector3 = (direction
		* speed_default
		* speed_modifier
		* crouch_speed_modifier);
	me.velocity.x = lerp(me.velocity.x, target.x, accel_factor * delta);
	me.velocity.z = lerp(me.velocity.z, target.z, accel_factor * delta);

func fall_vel_processor(delta: float) -> void:
	me.velocity.y -= Settings.gravity * 60 * delta;

func play_transition_to_ledged() -> void:
	$LedgedTransitioner.play("transition_to_ledged");

func play_climb() -> void:
	$Climber.play("climb");

func play_vault() -> void:
	$Vaulter.play("vault");

func play_slide() -> void:
	$Slider.play("sliding");

#func reset_ledged_transitioner() -> void:
	#$LedgedTransitioner.play("RESET");
