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
	Signals.player_ledged.connect(_on_player_ledged);

func _physics_process(delta: float) -> void:
	if (!stop_rotating):
		rotation = %HeadPC.rotation;

func _on_player_ledged() -> void:
	global_position.y = %ClimbCasts.hor_col_pos.y;

func _on_ledger_positioned() -> void:
	stop_rotating = true;
	basis = Basis.looking_at(-%ClimbCasts.hor_col_norm_backup);

func _on_out_of_ledged() -> void:
	print("outta ledged.");
	stop_rotating = false;

func left_possible() -> bool:
	if (above_left.is_colliding()):
		return false;
	if (!below_left.is_colliding()):
		return false;
	return true;

func right_possible() -> bool:
	if (above_right.is_colliding()):
		return false;
	if (!below_right.is_colliding()):
		return false;
	return true;
