extends Node

var speed_default: float = 700.0;
var speed_modifier: float = 1.0;
var crouch_speed_modifier: float = 1.0;
var slide_modifier: float = 1.5;
var slide_post_modifier: float = 0.7;
var last_direction: Vector3 = Vector3(0, 0, 0);

var is_walking_bc_input: bool = false;

var ready_to_slide: bool = false;
#var ready_to_slide: bool;
