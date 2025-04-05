extends Node3D

@onready var asp = $Music

var volume = -10

var music_paths = [
	"res://music/whisper_tree.mp3",
	"res://music/whispers_shadow.mp3",
	"res://music/whisper_dark.mp3"
]

func _ready() -> void:
	randomize()
	var chosen_path = music_paths[randi() % music_paths.size()]
	
	asp.stream = load(chosen_path)
	AudioServer.set_bus_volume_db(0, volume)
	asp.play()
	
	asp.finished.connect(_on_song_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		asp.stream_paused = !asp.stream_paused

func _on_song_finished():
	var chosen_path = music_paths[randi() % music_paths.size()]
	asp.stream = load(chosen_path)
	asp.play()
