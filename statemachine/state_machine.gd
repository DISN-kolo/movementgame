## https://shaggydev.com/2023/10/08/godot-4-state-machines/
class_name StateMachine
extends Node

@export var starting_state: State;

var current_state: State = null;
var global_actor: CharacterBody3D = null;

func init(actor: CharacterBody3D) -> void:
	global_actor = actor;
	for child in get_children():
		child.actor = actor;
	change_state(starting_state);

func change_state(new_state: State) -> void:
	global_actor.label_state.set_text(new_state.get_name());
	if (current_state):
		current_state.exit();
	current_state = new_state;
	new_state.enter();

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event);
	if (new_state):
		change_state(new_state);

func process_default(delta: float) -> void:
	var new_state = current_state.process_default(delta);
	if (new_state):
		change_state(new_state);

func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta);
	if (new_state):
		change_state(new_state);
