extends Node3D
class_name HandCasts;

@onready var above_left: RayCast3D = %AboveLeft;
@onready var above_right: RayCast3D = %AboveRight;
@onready var below_left: RayCast3D = %BelowLeft;
@onready var below_right: RayCast3D = %BelowRight;
