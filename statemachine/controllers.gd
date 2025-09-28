extends Node

@onready var crouch_fatigue_timer: Timer = $CrouchFatigueTimer

var speed_default: float = 700.0;
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
