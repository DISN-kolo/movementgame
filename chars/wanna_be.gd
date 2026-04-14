extends Area3D;

#var has_geometry_inside: bool = false;

func _ready() -> void:
	#var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	#var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new();
	#query.collision_mask = collision_mask;
	#query.exclude = [get_rid()];
	#query.shape = %WannaBeLedgedCollisionShape.shape;
	#query.transform = %WannaBeLedgedCollisionShape.global_transform;
#
	#var results: Array = space_state.intersect_shape(query);
	#print("ledge check: ", results);
	#has_geometry_inside = !(results.is_empty());
	#
	#has_geometry_inside = has_overlapping_bodies();
	pass ;
