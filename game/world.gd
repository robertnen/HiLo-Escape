extends Node3D

@onready var asp = $Music
@onready var bec = $Bec
@onready var cam = $Camera3D
@onready var pause_menu = $PauseMenu
@onready var pause_panel = $PauseMenu/CanvasLayer

@onready var start_button = $"Main Menu/Menu/MarginContainer/VBoxContainer/StartGameButton"
@onready var menu_panel = $"Main Menu"

@onready var pause_continue_btn = $PauseMenu/CanvasLayer/Panel/Continue_btn
@onready var pause_exit_menu_btn = $PauseMenu/CanvasLayer/Panel/Menu_btn
@onready var pause_exit_btn = $PauseMenu/CanvasLayer/Panel/Quit_btn

@onready var hud = $HUD/CanvasLayer

@onready var ending = $ending

@onready var toanta = $WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab

const SCALE = 0.3

var money_player = 5
var money_antago = 5

var is_ending: bool = false

const TIME_BETWEEN_ROUNDS = 5 # seconds

var level = 0
# 0 - inceput, prea devreme
# 1 - prima runda - de aici se poate da save
# ...

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
@onready var anim_bad_ending_1 = $eye3/AnimationPlayer

@onready var eye_3 = $eye3

func _ready() -> void:
	hud.visible = false
	asp.volume_db = VOLUME_DB
	eye_audio.volume_db = 5
	eye_audio_2.volume_db = 5
	ending.volume_db = 5
	AudioServer.set_bus_volume_db(0, volume)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	start_button.connect("pressed", Callable(self, "_start_game"))
	pause_continue_btn.connect("pressed", Callable(self, "_continue_game"))
	pause_exit_menu_btn.connect("pressed", Callable(self, "_exit_to_menu"))
	pause_exit_btn.connect("pressed", Callable(self, "_exit_game"))
	
	asp.finished.connect(_on_song_finished)
	
	start_game()

func start_game():
	Input.warp_mouse(Vector2(1583.0, 84.0))
	eye_3.visible = false
	
	cam.rotate_x(-14.3)
	cam.rotate_y(-77.2)
	cam.rotate_z(0.0)
	
	game_elapsed_time = 0
	time_elapsed = 0
	eye_elapsed = 0
	eye_elapsed_2 = 0
	
		# ascunde lucruri
	pause_menu.visible = false
	pause_panel.visible = false

	# media player-ul cu ost-ul jocului
	randomize()
	var chosen_path = music_paths[randi() % music_paths.size()]
	
	eye_audio.stream = load("res://music/lala.mp3")
	eye_audio_2.stream = load("res://music/lala.mp3")
	
	asp.stream = load(chosen_path)
	asp.play()
	
	# luminca de la bef, efect fade-in
	bec.light_energy = 0.
	
	eye_time_to_start = randi() % 1 + 3
	eye_time_to_start_2 = randi() % 1 + 5
	toanta.position = Vector3(-28.392, 0.103, -124.283)
	var toanta_iar = get_node("WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab")
	var toanta_anim = get_node("WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab/AnimationPlayer")
	toanta_iar.time_elapsed = 0.
	toanta_iar.direction = -Vector3.LEFT
	
	toanta_anim.get_animation("Girl_Anim_Walk").loop = true
	toanta_anim.play("Girl_Anim_Walk")


var caro_arr = []
var pos_1 = Vector3(-32.272, 1.326, -121.187)
var pos_2 = Vector3(-32.209, 1.321, -120.894)
var pos_3 = Vector3(-32.146, 1.317, -120.601)
var pos_4 = Vector3(-32.082, 1.312, -120.308)
var pos_5 = Vector3(-32.019, 1.308, -120.014)

func add_card(card: PackedScene, pos: Vector3, ang: Vector3 = Vector3(-77.3, 98.3, 3.9)):
	var inst = card.instantiate()
	inst.position = pos
	inst.scale = Vector3(SCALE, SCALE, SCALE)
	inst.rotation_degrees = ang
	
	caro_arr.append(inst)
	add_child(inst)

func remove_card():
	for inst in caro_arr:
		if is_instance_valid(inst):
			inst.queue_free()
			
	caro_arr.clear()

func display_cards(round_player: Array[PackedScene]):
	add_card(round_player[0], pos_1)
	add_card(round_player[1], pos_2)
	add_card(round_player[2], pos_3)
	add_card(round_player[3], pos_4)
	add_card(round_player[4], pos_5)
	
func display_cards_anta(round_anta: Array[PackedScene]):
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and is_menu == false:
		asp.stream_paused = !asp.stream_paused
		toggle_pause(delta)
		
	if Input.is_action_just_pressed("fullscreen_toggle"):
		toggle_fullscreen()
		
	if is_menu or is_paused:
		return
	
	hud.visible = true
		
	if time_elapsed < fade_duration && fade_duration != 0:
		@warning_ignore("integer_division")
		bec.light_energy = lerp(0., light_target, time_elapsed / fade_duration)
	
	time_elapsed += delta
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

		if abs(yaw_deg - 60) < 5:
			eye_audio.stop()
			asp.volume_db += 10
			eye_flag = false
			eye.hide()
			eye_time_to_start = game_elapsed_time + randi() % 50
			eye_elapsed = 0
			
		if eye_elapsed > EYE_DURATION:
			eye_audio.stop()
			eye_audio_2.stop()
			Input.warp_mouse(Vector2(1483.0, 153.0))
			
			if !is_ending:
				ending.stream = load("res://music/bad_end_cut_1.mp3")
				ending.play()
				is_ending = true
				eye_3.visible = true
				anim_bad_ending_1.get_animation("ATK").loop = true
				anim_bad_ending_1.play("ATK")

			if eye_elapsed > EYE_DURATION + 3:
				anim_bad_ending_1.stop()
				eye_3.visible = false
				is_ending = false;
				ending.stop()
				_exit_to_menu()
		
		eye_elapsed += delta
		
	if game_elapsed_time >= eye_time_to_start_2:
		if eye_flag_2 == false:
			eye_2.show()
			eye_flag_2 = true
			eye_audio_2.play()
			asp.volume_db -= 10
			
		var yaw_deg = rad_to_deg(cam.rotation.y)

		if abs(yaw_deg - -120) < 5:
			eye_audio_2.stop()
			asp.volume_db += 10
			eye_flag_2 = false
			eye_2.hide()
			eye_time_to_start_2 = game_elapsed_time + randi() % 50
			eye_elapsed_2 = 0
			
		if eye_elapsed_2 > EYE_DURATION:
			eye_audio.stop()
			eye_audio_2.stop()
			Input.warp_mouse(Vector2(1433.0, 123.0))
			
			if !is_ending:
				ending.stream = load("res://music/bad_end_cut_1.mp3")
				ending.play()
				is_ending = true
				eye_3.visible = true
				anim_bad_ending_1.get_animation("ATK").loop = true
				anim_bad_ending_1.play("ATK")

			if eye_elapsed_2 > EYE_DURATION + 3:
				anim_bad_ending_1.stop()
				eye_3.visible = false
				is_ending = false;
				ending.stop()
				_exit_to_menu()
		
		eye_elapsed_2 += delta

	if game_elapsed_time > 5: # runda 1
		pass

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

	if eye_flag and is_paused:
		eye_audio.stream_paused = true
		
	if eye_flag and !is_paused:
		eye_audio.stream_paused = false
		
	if eye_flag_2 and is_paused:
		eye_audio_2.stream_paused = true
		
	if eye_flag_2 and !is_paused:
		eye_audio_2.stream_paused = false
		
	if ending and is_paused:
		ending.stream_paused = true
		anim_bad_ending_1.stop()
		
	if ending and !is_paused:
		ending.stream_paused = false
		anim_bad_ending_1.get_animation("ATK").loop = true
		anim_bad_ending_1.play("ATK")
		
	var toanta_iar = get_node("WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab")
	var toanta_anim = get_node("WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab/AnimationPlayer")	
	
	if !is_paused:
		toanta_anim.get_animation("Girl_Anim_Walk").loop = true
		toanta_anim.play("Girl_Anim_Walk")
	
	get_tree().paused = is_paused
	asp.stream_paused = !asp.stream_paused
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
	eye_3.visible = false
	is_menu = false
	menu_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	start_game()
	
func _continue_game():
		toggle_pause(0)
		
func _exit_to_menu():
		hud.visible = false
		is_paused = false
		is_menu = true
		eye_3.visible = false
		pause_panel.visible = false
		menu_panel.visible = true
		eye.visible = false
		eye_2.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _exit_game():
	get_tree().quit()
