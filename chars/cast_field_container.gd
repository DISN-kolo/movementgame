extends Node3D

var x_rad: int = 4;
var z_len: int = 20;
var spacer: float = 0.198/1.6;
var central_pos: Vector3 = Vector3(0.0, 2.06, -0.532);

const SINGLE_CAST_FOR_FIELD = preload("uid://cimq22qri4u6f");
var scff_i: SingleCastForField = null;

var casts_references: Dictionary[Vector2i, SingleCastForField];
var tgt_pos = Vector3(0, -3.055, 0);

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

func _physics_process(delta: float) -> void:
	for z in range(0, z_len + 1):
		var cty: int = 0;
		var max_cty: int = 0;
		for x in range(-x_rad + 1, x_rad):
			if (casts_references[Vector2i(x, z)].is_colliding()):
				cty += 1;
			else:
				cty = 0;
			if (cty > max_cty):
				max_cty = cty;
		if (max_cty >= x_rad - 1):
			mark_row(z);
		else:
			unmark_row(z);

func mark_row(z: int):
	for x in range(-x_rad, x_rad + 1):
		casts_references[Vector2i(x, z)].get_marked();

func unmark_row(z: int):
	for x in range(-x_rad, x_rad + 1):
		casts_references[Vector2i(x, z)].get_unmarked();
