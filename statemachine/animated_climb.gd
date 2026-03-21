extends State

@export var controllers: Node

@export var idle_state: Node

var starting_position: Vector3;
var ending_position: Vector3;
@export var parameter: float = 0.0;

var returned_state: State = null;

func enter() -> void:
	returned_state = null;
	parameter = 0.0;
	controllers.is_walking_bc_input = false;
	super();
	starting_position = actor.position;
	ending_position = (actor.climb_casts.top_col_pos
		+ Vector3(0, actor.default_capsule_height/2, 0));
	controllers.play_climb();

func process_physics(delta: float) -> State:
	actor.velocity = Vector3(0.0, 0.0, 0.0);
	actor.position = lerp(starting_position, ending_position, parameter);
	return returned_state;

# TODO enters Ledged State upon animation finish
func start_returning_idle() -> void:
	returned_state = idle_state;
