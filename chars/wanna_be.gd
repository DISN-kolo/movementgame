extends Area3D

func _ready() -> void:
	print(get_tree().get_current_scene());
	reparent(get_tree().get_current_scene());
	print(get_parent());
