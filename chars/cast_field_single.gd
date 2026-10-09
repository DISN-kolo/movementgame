extends RayCast3D
class_name SingleCastForField;

const BRICK_EXEMPLAR = preload("uid://clbwypf3yvq2m");
var instance_brick: BrickExemplar = null;
var alr_coll: bool = false;

func _ready() -> void:
	instance_brick = BRICK_EXEMPLAR.instantiate();
	instance_brick.position = target_position;
	add_child(instance_brick);

func _physics_process(delta: float) -> void:
	if (is_colliding()):
		instance_brick.scale.y = (get_collision_point().y -
			instance_brick.global_position.y) + 0.01;
	if (is_colliding() and not alr_coll):
		instance_brick.set_vis();
		alr_coll = true;
	elif (not is_colliding() and alr_coll):
		instance_brick.set_invis();
		alr_coll = false;

func get_marked():
	instance_brick.get_marked();

func get_unmarked():
	instance_brick.get_unmarked();
