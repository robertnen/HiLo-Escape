extends Node3D

@onready var asp = $Music
@onready var bec = $Bec
@onready var cam = $Camera3D
@onready var pause_menu = $PauseMenu
@onready var pause_panel = $PauseMenu/CanvasLayer

@onready var start_button = $"Main Menu/Menu/MarginContainer/VBoxContainer/StartGameButton"
@onready var menu_panel = $"Main Menu"

var is_paused = false
var is_menu = true

const VOLUME_DB = -21.333 # pt streaming
const EYE_DURATION = 14

var volume = -10 # adauga aici din meniu
var volume_sfx = -10 # adauga aici din meniu

var music_paths = [
	"res://music/whisper_tree.mp3",
	"res://music/whispers_shadow.mp3",
	"res://music/whisper_dark.mp3"
]

var game_elapsed_time = 0

# lumini
var light_target = 2.293
var fade_duration = 10
var time_elapsed = 0

# monstru_1
var eye_time_to_start = 0
var eye_elapsed = 0
var eye_flag = false;
@onready var eye = $eye
@onready var eye_audio = $eye/eye_stream

# monstru_2
var eye_time_to_start_2 = 0
var eye_elapsed_2 = 0
var eye_flag_2 = false;
@onready var eye_2 = $eye2
@onready var eye_audio_2 = $eye2/eye_stream_2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# ascunde lucruri
	pause_menu.visible = false
	pause_panel.visible = false
	
	start_button.connect("pressed", Callable(self, "_start_game"));

	# media player-ul cu ost-ul jocului
	randomize()
	var chosen_path = music_paths[randi() % music_paths.size()]
	
	asp.volume_db = VOLUME_DB
	eye_audio.volume_db = 5
	eye_audio_2.volume_db = 5
	
	eye_audio.stream = load("res://music/lala.mp3")
	eye_audio_2.stream = load("res://music/lala.mp3")
	
	asp.stream = load(chosen_path)
	AudioServer.set_bus_volume_db(0, volume)
	asp.play()
	
	asp.finished.connect(_on_song_finished)
	
	# luminca de la bef, efect fade-in
	bec.light_energy = 0.
	
	eye_time_to_start = randi() % 10 + 10
	eye_time_to_start_2 = randi() % 10 + 20

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		asp.stream_paused = !asp.stream_paused
		toggle_pause(delta)
		
	if Input.is_action_just_pressed("fullscreen_toggle"):
		toggle_fullscreen()
		
	if is_menu:
		return
		
	if time_elapsed < fade_duration && fade_duration != 0:
		bec.light_energy = lerp(0., light_target, time_elapsed / fade_duration)
	
	time_elapsed += delta
	#if time_elapsed > 20:
		#time_elapsed = 0
		#bec.light_energy = 0.
		
	game_elapsed_time += delta
	
	if game_elapsed_time > 1000:
		game_elapsed_time = 0
		
	if game_elapsed_time >= eye_time_to_start:
		if eye_flag == false:
			eye.show()
			eye_flag = true
			eye_audio.play()
			asp.volume_db -= 10
			
		var yaw_deg = rad_to_deg(cam.rotation.y)

		if abs(yaw_deg - -120) < 5:
			eye_audio.stop()
			asp.volume_db += 10
			eye_flag = false
			eye.hide()
			eye_time_to_start = game_elapsed_time + randi() % 50
			eye_elapsed = 0
			
		if eye_elapsed > EYE_DURATION:
			eye_audio.stop()
			# adauga ending
		
		eye_elapsed += delta
		
	if game_elapsed_time >= eye_time_to_start_2:
		if eye_flag_2 == false:
			eye_2.show()
			eye_flag_2 = true
			eye_audio_2.play()
			asp.volume_db -= 10
			
		var yaw_deg = rad_to_deg(cam.rotation.y)

		if abs(yaw_deg - 60) < 5:
			eye_audio_2.stop()
			asp.volume_db += 10
			eye_flag_2 = false
			eye_2.hide()
			eye_time_to_start_2 = game_elapsed_time + randi() % 50
			eye_elapsed_2 = 0
			
		if eye_elapsed_2 > EYE_DURATION:
			eye_audio_2.stop()
			# adauga ending
		
		eye_elapsed_2 += delta

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_song_finished():
	var chosen_path = music_paths[randi() % music_paths.size()]
	asp.stream = load(chosen_path)
	asp.play()

func toggle_pause(delta: float):
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	pause_panel.visible = is_paused
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		bec.light_energy = 0.5
		eye_time_to_start += delta
		eye_time_to_start_2 += delta
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		bec.light_energy = light_target
		
func _start_game():
	is_menu = false
	menu_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
