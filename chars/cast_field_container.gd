extends Node3D

var x_rad: int = 3;
var z_len: int = 10;
var spacer: float = 0.198;
var central_pos: Vector3 = Vector3(0.0, 1.06, -0.532);

const SINGLE_CAST_FOR_FIELD = preload("uid://cimq22qri4u6f");
var scff_i: SingleCastForField = null;

var casts_references: Dictionary[Vector2i, RayCast3D];
var tgt_pos = Vector3(0, -2.055, 0);

func _ready() -> void:
	for x in range(-x_rad, x_rad + 1):
		for z in range(0, z_len + 1):
			scff_i = SINGLE_CAST_FOR_FIELD.instantiate();
			scff_i.position = central_pos + Vector3(
				x * spacer,
				0,
				- z * spacer
			);
			scff_i.target_position = tgt_pos;
			add_child(scff_i);
			casts_references[Vector2i(x, z)] = scff_i;
