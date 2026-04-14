extends Area3D;

var has_geometry_inside: bool = false;

func _ready() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new();
	query.collision_mask = collision_mask;
	query.exclude = [get_rid()];
	query.shape = %WannaBeUpCollisionShape.shape;
	query.transform = %WannaBeUpCollisionShape.global_transform;

	var results: Array = space_state.intersect_shape(query);
	has_geometry_inside = !(results.is_empty());
