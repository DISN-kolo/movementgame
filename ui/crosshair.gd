extends ColorRect

func _ready() -> void:
	position.x = get_viewport().size.x / 2 - 3;
	position.y = get_viewport().size.y / 2 - 3;
	size.x = 6;
	size.y = 6;
	pass
