class_name CrouchState
extends Node

#@export var animation_name: String;

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Hold a reference to the parent so that it can be controlled by the state
var actor: CharacterBody3D

func enter() -> void:
	#parent.animations.play(animation_name)
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> CrouchState:
	return null

func process_default(delta: float) -> CrouchState:
	return null

func process_physics(delta: float) -> CrouchState:
	return null
