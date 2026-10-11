extends Node3D

var x_rad: int = 4;
var z_len: int = 20;
var spacer: float = 0.198/1.6;
var central_pos: Vector3 = Vector3(0.0, 2.06, -0.532);

var ledge_row_z: int = -1;

const SINGLE_CAST_FOR_FIELD = preload("uid://cimq22qri4u6f");
var scff_i: SingleCastForField = null;

var casts_references: Dictionary[Vector2i, SingleCastForField];
var tgt_pos = Vector3(0, -3.055, 0);

var pc_ref: Player = null;

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
	ledge_row_z = -1;
	for z in range(0, z_len + 1):
		var count: int = 0;
		var max_count: int = 0;
		var min_h_temp: float = 10e100;
		var max_h_temp: float = -10e100;
		for x in range(-x_rad + 1, x_rad):
			var current_cast: SingleCastForField = casts_references[
				Vector2i(x, z)
			];
			if (current_cast.is_colliding()):
				count += 1;
				var cur_col_y: float = current_cast.get_collision_point().y;
				if (cur_col_y < min_h_temp):
					min_h_temp = cur_col_y;
				if (cur_col_y > max_h_temp):
					max_h_temp = cur_col_y;
			else:
				count = 0;
				min_h_temp = 10e100;
				max_h_temp = -10e100;
			if (max_h_temp - min_h_temp > 0.45):
				count = 0;
				min_h_temp = 10e100;
				max_h_temp = -10e100;
			if (count > max_count):
				max_count = count;
		if (max_count >= x_rad - 1):
			if (ledge_row_z == -1):
				ledge_row_z = z;
			mark_row(z);
		else:
			unmark_row(z);

func mark_row(z: int):
	for x in range(-x_rad, x_rad + 1):
		casts_references[Vector2i(x, z)].get_marked();

func unmark_row(z: int):
	for x in range(-x_rad, x_rad + 1):
		casts_references[Vector2i(x, z)].get_unmarked();
