extends Area3D;

func _ready() -> void:
	Signals.move_wanna_be_up.connect(get_moved);

func _physics_process(delta: float) -> void:
	Globals.current_wbu_pos = global_position;

func get_moved(newpos: Vector3) -> void:
	global_position = newpos;
