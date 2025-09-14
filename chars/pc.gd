extends CharacterBody3D;

@onready var head_pc: Node3D = $HeadPC;
@onready var camera_pc: Camera3D = $HeadPC/CameraPC;

var input_dir: Vector2 = Vector2(0, 0);
var direction: Vector3 = Vector3(0, 0, 0);
var speed_modifier: float = 500.0;

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		head_pc.rotate_y(-event.relative.x * Settings.sensitivity);
		camera_pc.rotate_x(-event.relative.y * Settings.sensitivity);
		camera_pc.rotation.x = clamp(camera_pc.rotation.x, -PI/2, PI/2);

func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down");
	direction = (head_pc.transform.basis * Vector3(input_dir.x, 0, input_dir.y));
	velocity = direction * speed_modifier * delta;
	print(velocity);
	move_and_slide();
