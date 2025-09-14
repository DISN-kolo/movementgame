extends Node3D;
@onready var world0 = preload("res://worlds/world_0.tscn");
var worldinstance;
@onready var PC = preload("res://chars/pc.tscn");
var playerinstance: CharacterBody3D;

func _ready() -> void:
	worldinstance = world0.instantiate();
	self.add_child(worldinstance);
	playerinstance = PC.instantiate();
	playerinstance.position.y += 1;
	self.add_child(playerinstance);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	pass;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit();
	elif event.is_action_pressed("sens_up"):
		Settings.sensitivity += 0.001;
	elif event.is_action_pressed("sens_down"):
		Settings.sensitivity -= 0.001;
