class_name CrouchMachine
extends Node

@export var starting_state: CrouchState;

var current_state: CrouchState = null;
var global_actor: CharacterBody3D = null;

func init(actor: CharacterBody3D) -> void:
	global_actor = actor;
	for child in get_children():
		child.actor = actor;
	change_state(starting_state);

func change_state(new_state: CrouchState) -> void:
	if (current_state):
		current_state.exit();
	if (new_state == null):
		return ;
	if global_actor.is_debugging:
		global_actor.label_c_state.set_text(new_state.get_name());
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
