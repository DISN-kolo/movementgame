extends Node3D

@onready var right_ear: AudioStreamPlayer3D = $RightEar
@onready var left_ear: AudioStreamPlayer3D = $LeftEar

# always start walking with the right leg
var right_must_play: bool = true;
var steps_slow_wavs: Array[AudioStreamWAV] = [];
var steps_fast_wavs: Array[AudioStreamWAV] = [];

func _ready() -> void:
	randomize();
	var dir = DirAccess.open("res://resources/sounds/steps");
	if dir:
		dir.list_dir_begin();
		var filename: String = dir.get_next();
		while (filename != ""):
			if (!filename.ends_with("import")):
				if (filename.find("fast") != -1):
					steps_fast_wavs.append(
						load(dir.get_current_dir().path_join(filename))
					);
				elif (filename.find("slow") != -1):
					steps_slow_wavs.append(
						load(dir.get_current_dir().path_join(filename))
					);
			filename = dir.get_next();

func play_next_slow_step() -> void:
	var random_sound: AudioStreamWAV = steps_slow_wavs[randi_range(
		0, steps_slow_wavs.size() - 1
	)];
	play_next_step(random_sound);

func play_next_fast_step() -> void:
	var random_sound: AudioStreamWAV = steps_fast_wavs[randi_range(
		0, steps_fast_wavs.size() - 1
	)];
	play_next_step(random_sound);

func play_next_step(sound: AudioStreamWAV) -> void:
	if (right_must_play):
		right_ear.stream = sound;
		right_ear.pitch_scale = randf_range(0.95, 1);
		right_ear.play();
	else:
		left_ear.stream = sound;
		left_ear.pitch_scale = randf_range(0.95, 1);
		left_ear.play();
	right_must_play = !right_must_play;
