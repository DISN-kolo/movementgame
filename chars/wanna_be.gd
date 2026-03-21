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

	# TODO: ignore intersections with particular node groups
	# like collectibles or whatever
	#var ignored_groups: Array[StringName] = [];
	#var filtered: Array = [];
	#for hit in results:
		#var collider: Node = hit.get("collider");
		#var ignored: bool = false;
		#for group in ignored_groups:
			#if (collider != null and collider.is_in_group(group)):
				#ignored = true;
				#break;
		#if (not ignored):
			#filtered.append(hit);
	#has_geometry_inside = not filtered.is_empty();
