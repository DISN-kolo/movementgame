extends Node3D

@onready var head_pc: Node3D = %HeadPC
@onready var pc: Player = get_parent()

var default_offset: Vector3 = Vector3.ZERO;

func _ready() -> void:
	default_offset = head_pc.position - position;

func _physics_process(delta: float) -> void:
	rotation.y = head_pc.rotation.y;
	position.y = lerp(
		position.y,
		pc.current_head_y - default_offset.y,
		5.0 * delta);
