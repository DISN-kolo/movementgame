extends CharacterBody3D;

@onready var head_pc: Node3D = $HeadPC;
@onready var camera_pc: Camera3D = $HeadPC/CameraPC;
const SENSITIVITY = 0.003;

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head_pc.rotate_y(-event.relative.x * SENSITIVITY);
		camera_pc.rotate_x(event.relative.y * SENSITIVITY);
		camera_pc.rotation.x = clamp(camera_pc.rotation.x, -PI/2, PI/2);
