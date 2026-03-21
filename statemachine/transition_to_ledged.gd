extends State

@export var controllers: Node

@export var ledged_state: Node

func enter() -> void:
	controllers.is_walking_bc_input = false;
	super();

# TODO enters Ledged State upon animation finish
