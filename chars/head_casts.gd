extends Node3D

@onready var head_pc: Node3D = %HeadPC
@onready var pc: Player = get_parent()

func _physics_process(delta: float) -> void:
	rotation.y = head_pc.rotation.y
	position.y = lerp(position.y, pc.current_head_y, 5.0 * delta)
