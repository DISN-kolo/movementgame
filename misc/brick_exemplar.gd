extends Node3D
class_name BrickExemplar;

const HIGHLIGHT = preload("uid://d3bebav8wj2hy");

var defcol: Color = Color("ffffff45");
var goodcol: Color = Color("00ff0070");

func set_invis():
	%MeshInstance3D.visible = false;

func set_vis():
	%MeshInstance3D.visible = true;

func get_marked():
	%MeshInstance3D.set_instance_shader_parameter("active", true);

func get_unmarked():
	%MeshInstance3D.set_instance_shader_parameter("active", false);
