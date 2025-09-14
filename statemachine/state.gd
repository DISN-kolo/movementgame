class_name State
extends Node

#@export var animation_name: String;
var speed_modifier: float = 500;
var air_speed_modifier: float = 0.6;

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Hold a reference to the parent so that it can be controlled by the state
var actor: CharacterBody3D

func enter() -> void:
	#parent.animations.play(animation_name)
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_default(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
