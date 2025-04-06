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

@onready var ending = $ending

@onready var toanta = $WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab

const SCALE = 0.3

var money_player = 5
var money_antago = 5

var is_ending: bool = false

const TIME_BETWEEN_ROUNDS = 5 # seconds

var aux_time = 0
var level = 0
# 0 - inceput, prea devreme
# 1 - prima runda - de aici se poate da save
# ...

var is_paused = false
var is_menu = true

var bet = 0

const VOLUME_DB = -21.333 # pt streaming
const EYE_DURATION = 14

var volume = -10 # adauga aici din meniu
var volume_sfx = -10 # adauga aici din meniu

var is_chosen = false
var choice = false

const ROUND_1 = 2
const ROUND_2 = 3

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

@onready var hud_1 = $HUD/round_1

@onready var hud = $HUD/CanvasLayer
@onready var subtitle = $HUD/CanvasLayer2
@onready var subs = $HUD/CanvasLayer2/toanta
@onready var tip_money = $HUD/CanvasLayer2/tip
@onready var tip_hl = $HUD/CanvasLayer2/tip2
@onready var tip_time = $HUD/CanvasLayer2/tip3
@onready var win_label = $HUD/CanvasLayer2/win
@onready var lose_label = $HUD/CanvasLayer2/lose

@onready var flash = $HUD/Panel

@onready var rewind_aud = $rewind
@onready var no_rewind_aud = $no_rewind

var flash_time = 10.
var elapsed_time = 0.
var flash_state = 0

var is_starting = false

var flag_round_1 = false
var flag_round_2 = true

var ending_round_1 = false
var ending_round_2 = false
var key_pressed_value = null

func _flash(delta: float):
	if (!is_paused):
		elapsed_time += delta
	else:
		return
	
	match flash_state:
		0:
			flash.modulate.a = elapsed_time / flash_time
			if elapsed_time >= flash_time:
				flash_state = 1
				elapsed_time = 0
				flash.modulate.a = 1
		1:
			if elapsed_time >= flash_time:
				flash_state = 2
				elapsed_time = 0 
		2:
			flash.modulate.a = 1 - (elapsed_time / flash_time)
			if elapsed_time >= flash_time:
				flash_state = 0
				elapsed_time = 0
				flash.modulate.a = 0

func _ready() -> void:
	hud.visible = false
	hud_1.visible = false
	subtitle.visible = false
	win_label.visible = false
	lose_label.visible = false
	asp.volume_db = VOLUME_DB
	eye_audio.volume_db = 5
	eye_audio_2.volume_db = 5
	ending.volume_db = 5
	rewind_aud.volume_db = 10
	no_rewind_aud.volume_db = 10
	AudioServer.set_bus_volume_db(0, volume)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	rewind_aud.stream = load('res://music/rewind_time.mp3')
	no_rewind_aud.stream = load('res://music/not_doing_it.mp3')
	
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
	
	eye_time_to_start = randi() % 10 + 20
	eye_time_to_start_2 = randi() % 10 + 10
	toanta.position = Vector3(-28.392, 0.103, -124.283)
	var toanta_iar = get_node("WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab")
	var toanta_anim = get_node("WorldEnvironment/Spooky_Summer_Nightmare_Girl_Sketchfab/AnimationPlayer")
	toanta_iar.time_elapsed = 0.
	toanta_iar.direction = -Vector3.LEFT
	
	toanta_anim.get_animation("Girl_Anim_Walk").loop = true
	toanta_anim.play("Girl_Anim_Walk")
	
	is_starting = false

func display_cards_1():
	bet = 0
	var n7 = get_node('7N')
	var r3 = get_node('3R')
	var r2 = get_node('2R')
	var c2 = get_node('2C')
	var t3 = get_node('3T')
	
	n7.visible = true
	r3.visible = true
	r2.visible = true
	c2.visible = true
	t3.visible = true
	
	subs.text = "Witch: I bet 2"
	subtitle.visible = true
	tip_hl.visible = false
	tip_time.visible = false
	tip_money.visible = false
	hud_1.visible = false

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
	
	if game_elapsed_time > 7 and !flag_round_1: # runda 1
		if !is_starting:
			display_cards_1()
			is_starting = true
			
		subs.text = "Witch: Do I have a higher set?"
		subs.visible = true
		
		if game_elapsed_time > 12:
			subs.text = "Witch: Hmmm... Maybe...."
			
		if game_elapsed_time > 17:
			subs.text = "Witch: I'll chose... High! What\n do you think?"
			
		if game_elapsed_time > 20:
			tip_hl.visible = true
			
		if game_elapsed_time < 22:
			return

		if Input.is_key_pressed(KEY_H) and !ending_round_2:
			ending_round_1 = true
			aux_time = game_elapsed_time
			tip_hl.visible = false
		
		if Input.is_key_pressed(KEY_L) and !ending_round_1:
			ending_round_2 = true
			aux_time = game_elapsed_time
			tip_hl.visible = false

		if ending_round_2 and game_elapsed_time > aux_time + 1:
			subs.text = "You: Low!"

		if ending_round_2 and game_elapsed_time > aux_time + 5:
			subs.text = "Witch: I won, maybe you can\n turn back in time!"
			hud_1.visible = true
			money_player = 4
			get_node("HUD/CanvasLayer/Label").text = str(money_player)

		if ending_round_2 and game_elapsed_time > aux_time + 7:
			tip_hl.visible = false
			tip_time.visible = true

		if ending_round_2 and game_elapsed_time > aux_time + 10:
			subs.text = "Witch: Time is ticking..."
			
		if ending_round_2 and game_elapsed_time > aux_time + 15:
			tip_hl.visible = false
			tip_time.visible = false
			flag_round_1 = true
			hud_1.visible = false
			no_rewind_aud.play()
			
		if ending_round_1 and game_elapsed_time > aux_time + 1:
			subs.text = "You: High!"

		if ending_round_1 and game_elapsed_time > aux_time + 5:
			subs.text = "Witch: What a lucky man!\n You need to win 4 more times!"
			hud_1.visible = true
			money_player = 6
			get_node("HUD/CanvasLayer/Label").text = str(money_player)

		if ending_round_1 and game_elapsed_time > aux_time + 7:
			tip_hl.visible = false
			tip_time.visible = true

		if ending_round_1 and game_elapsed_time > aux_time + 10:
			subs.text = "Witch: I feel that... you have some\n superpower?"
			
		if ending_round_1 and game_elapsed_time > aux_time + 15:
			subs.text = "Witch: Just my imagination..."
			tip_hl.visible = false
			tip_time.visible = false
			flag_round_1 = true
			hud_1.visible = false
			no_rewind_aud.play()
			
		if Input.is_key_pressed(KEY_K) and (ending_round_1 or ending_round_2):
			rewind_aud.play()
			tip_time.visible = false
			eye_elapsed = 0
			eye_elapsed_2 = 0

			flash_time = 1.
			elapsed_time = 0.
			flash_state = 0

			ending_round_1 = false
			ending_round_2 = false

			eye_audio.stop()
			eye_audio_2.stop()
			
			eye.visible = false
			eye_2.visible = false
			
			flash.visible = true
			_flash(delta)
			flash.visible = false
			
			game_elapsed_time = 4
			subs.visible = false
			
			money_player = 5
			get_node("HUD/CanvasLayer/Label").text = str(money_player)
			
			eye_time_to_start = game_elapsed_time + randi() % 50
			eye_time_to_start_2 = game_elapsed_time + randi() % 50
			

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

	rewind_aud.stream_paused = is_paused
	no_rewind_aud.stream_paused = is_paused

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
	hud_1.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	start_game()
	
func _continue_game():
		toggle_pause(0)
		
func _exit_to_menu():
		hud.visible = false
		subtitle.visible = false
		win_label.visible = false
		tip_hl.visible = false
		tip_money.visible = false
		tip_time.visible = false
		is_paused = false
		is_menu = true
		eye_3.visible = false
		pause_panel.visible = false
		menu_panel.visible = true
		eye.visible = false
		eye_2.visible = false
		hud_1.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _exit_game():
	get_tree().quit()
