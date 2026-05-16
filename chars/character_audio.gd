extends Node3D

@onready var right_ear: AudioStreamPlayer3D = $RightEar
@onready var left_ear: AudioStreamPlayer3D = $LeftEar

# always start walking with the right leg
var right_must_play: bool = true;
var steps_

func _ready() -> void:
	var dir = DirAccess.open("res://resources/sounds/steps");
	if dir:
		dir.list_dir_begin();
		var filename: String = dir.get_next();
		while (filename != ""):
			print("found file: ", filename);
			if (!filename.ends_with("import")):
				print("and it's an audio file!");
				
			filename = dir.get_next();

func play_next_slow_step() -> void:
	play_next_step();

func play_next_step() -> void:
	if (right_must_play):
		right_ear.play();
	else:
		left_ear.play();
	right_must_play = !right_must_play;
