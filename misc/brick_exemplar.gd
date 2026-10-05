extends Node3D
class_name BrickExemplar;

func set_invis():
	%MeshInstance3D.visible = false;

func set_vis():
	%MeshInstance3D.visible = true;
