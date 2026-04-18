class_name TransitionToLedged
extends State

@export var controllers: Node

@export var ledged_state: Node

var starting_position: Vector3;
var ending_position: Vector3;
@export var parameter: float = 0.0;

var returned_state: State = null;

func enter() -> void:
	actor.climb_casts.is_hopping = false;
	returned_state = null;
	parameter = 0.0;
	controllers.is_walking_bc_input = false;
	Signals.get_uncrouched.emit();
	super();
	starting_position = actor.position;
	ending_position = actor.wb_actual_position;
	controllers.play_transition_to_ledged();

func process_physics(delta: float) -> State:
	actor.velocity = Vector3(0.0, 0.0, 0.0);
	actor.position = lerp(starting_position, ending_position, parameter);
	return returned_state;

# TODO enters Ledged State upon animation finish
func start_returning_ledged() -> void:
	returned_state = ledged_state;
