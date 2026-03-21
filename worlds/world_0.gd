extends Node3D

var spawn_poss: Array[Vector3] = [];
var spawn_rots: Array[Vector3] = [];

func _ready() -> void:
	for node in $SpawnNodes.get_children():
		spawn_poss.append(node.position);
		spawn_rots.append(node.rotation);

func get_spawn_pos(id: int) -> Vector3:
	return spawn_poss[id];
	
func get_spawn_rot(id: int) -> Vector3:
	return spawn_rots[id];
