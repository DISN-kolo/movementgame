extends Node3D
class_name CastFieldContainer;

var x_rad: int = 4;
var z_len: int = 20;
var spacer: float = 0.198/1.6;
var central_pos: Vector3 = Vector3(0.0, 2.06, -0.532);

var ledge_row_z: int = -1;
var x_gap: int = 6;

const SINGLE_CAST_FOR_FIELD = preload("uid://cimq22qri4u6f");
var scff_i: SingleCastForField = null;

var casts_references: Dictionary[Vector2i, SingleCastForField];
var tgt_pos = Vector3(0, -3.055, 0);

var pc_ref: Player = null;

## Result of a single in_group_checker() pass.
class InGroupRes:
	var max_y: float = -INF;
	var min_y: float = INF;
	var second_min_y: float = INF;
	var totals: float = 0;
	var count: int = 0;
	var meanie: float = 0;
	var has_outlier: bool = false;
	var forgave_one: bool = false;

	func reset() -> void:
		max_y = -INF;
		min_y = INF;
		second_min_y = INF;
		totals = 0;
		count = 0;
		meanie = 0;
		has_outlier = false;
		forgave_one = false;

var group_res: InGroupRes = InGroupRes.new();

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
		var light_up_row: bool = false;
		for x_left in range(-x_rad, x_rad - x_gap + 2):
			var res: InGroupRes = in_group_checker(
				x_left,
				x_left + x_gap,
				z,
				0.1
			);
			if (res.has_outlier == false):
				light_up_row = true;
				break;
		if (light_up_row == true):
			mark_row(z);
		else:
			unmark_row(z);

## Just sets a cast row's prisms green.
func mark_row(z: int) -> void:
	for x in range(-x_rad, x_rad + 1):
		casts_references[Vector2i(x, z)].get_marked();

## Just returns a cast row's prisms to normal color.
func unmark_row(z: int) -> void:
	for x in range(-x_rad, x_rad + 1):
		casts_references[Vector2i(x, z)].get_unmarked();

## Checks if a group of casts in a row is eligible to be "vaultable".
## Returns the shared group_res instance
func in_group_checker(
		x_from: int,
		x_to: int,
		z: int,
		parameter: float) -> InGroupRes:
	var res: InGroupRes = group_res;
	res.reset();
	for x in range(x_from, x_to):
		var current_cast: SingleCastForField = casts_references[
			Vector2i(x, z)
		];
		if (current_cast.is_colliding() == false):
			if (res.forgave_one == false):
				res.forgave_one = true;
				continue;
			res.has_outlier = true;
			return res;
		var cur_col_y: float = current_cast.get_collision_point().y;
		res.max_y = max(cur_col_y, res.max_y);
		if (cur_col_y < res.min_y):
			res.second_min_y = res.min_y;
			res.min_y = cur_col_y;
		elif (cur_col_y < res.second_min_y):
			res.second_min_y = cur_col_y;
		res.totals += cur_col_y;
		res.count += 1;

	if (res.forgave_one == true):
		res.meanie = res.totals/res.count;
		res.has_outlier = (
			(res.max_y - res.meanie > parameter) or
			(res.meanie - res.min_y > parameter)
		);
		return res;

	if (res.count >= 2):
		var mean_without_lowest: float = (
			res.totals - res.min_y
		)/(res.count - 1);
		res.has_outlier = (
			(res.max_y - mean_without_lowest > parameter) or
			(mean_without_lowest - res.second_min_y > parameter)
		);
	return res;
