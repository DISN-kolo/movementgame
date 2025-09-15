class_name RunningState
extends Node

#@export var animation_name: String;
var sprint_modifier: float = 1.4;

# Hold a reference to the parent so that it can be controlled by the state
var actor: CharacterBody3D

func enter() -> void:
	#parent.animations.play(animation_name)
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> RunningState:
	return null

func process_default(delta: float) -> RunningState:
	return null

func process_physics(delta: float) -> RunningState:
	return null
