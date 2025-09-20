extends ColorRect

func _ready() -> void:
	self.position.x = get_viewport().size.x / 2 - 3;
	self.position.y = get_viewport().size.y / 2 - 3;
	self.size.x = 6;
	self.size.y = 6;
	pass
