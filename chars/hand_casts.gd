extends Node3D
class_name HandCasts;

@onready var above_left: RayCast3D = %AboveLeft;
@onready var above_right: RayCast3D = %AboveRight;
@onready var below_left: RayCast3D = %BelowLeft;
@onready var below_right: RayCast3D = %BelowRight;

var stop_rotating: bool = false;

func _ready() -> void:
	%Controllers.out_of_ledged.connect(_on_out_of_ledged);
	%ClimbCasts.positioned_ledger.connect(_on_ledger_positioned)

func _physics_process(delta: float) -> void:
	if (!stop_rotating):
		rotation = %HeadPC.rotation;

func _on_ledger_positioned() -> void:
	stop_rotating = true;
	global_position.y = %ClimbCasts.hor_col_pos.y;
	basis = Basis.looking_at(-%ClimbCasts.hor_col_norm_backup);
	print(%ClimbCasts.hor_col_pos);
	print(global_position)

func _on_out_of_ledged() -> void:
	print("outta ledged.");
	stop_rotating = false;

func left_impossible() -> bool:
	if (above_left.is_colliding()):
		return true;
	if (!below_left.is_colliding()):
		return true;
	return false;

func right_impossible() -> bool:
	if (above_right.is_colliding()):
		return true;
	if (!below_right.is_colliding()):
		return true;
	return false;
