extends Area3D;

var has_geometry_inside: bool = false;
var wall_norm: Vector3;

func _ready() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new();
	query.collision_mask = collision_mask;
	query.exclude = [get_rid()];
	query.shape = %WannaBeCollisionShape.shape;
	query.transform = %WannaBeCollisionShape.global_transform;

	var results: Array = space_state.intersect_shape(query);
	has_geometry_inside = !(results.is_empty());

	#var ignored_masks: int = 0b1;
	## debris and such should REALLY be in their own mask
	#var filtered: Array = [];
	#for hit in results:
		#var collider: Node = hit.get("collider");
		#if ((collider.collision_layer | ignored_masks) != collider.collision_layer):
			#filtered.append(hit);
	#has_geometry_inside = !(filtered.is_empty());
