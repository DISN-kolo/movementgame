extends Node3D;
@onready var world0 = preload("res://worlds/world_0.tscn");
var worldinstance;
@onready var PC = preload("res://chars/pc.tscn");
var playerinstance;

func _ready() -> void:
	worldinstance = world0.instantiate();
	self.add_child(worldinstance);
	playerinstance = PC.instantiate();
	self.add_child(playerinstance);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass;
