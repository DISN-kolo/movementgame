## https://shaggydev.com/2023/10/08/godot-4-state-machines/
class_name StateMachine
extends Node

@export var starting_state: State;

signal state_changed(state_name: String)

var current_state: State = null;

func init(actor: CharacterBody3D) -> void:
	for child in get_children():
		child.actor = actor;
	change_state(starting_state);

func change_state(new_state: State) -> void:
	if (current_state):
		current_state.exit();
	if (new_state == null):
		return ;
	state_changed.emit(new_state.get_name());
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
