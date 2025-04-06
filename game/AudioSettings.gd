extends Control

@onready var world = get_node("/root/world")

# script for audio settings
func _ready():
	$Volume_Slider.connect("value_changed", Callable(self, "_on_Volume_Slider_value_changed"))
	$SFX_Slider.connect("value_changed", Callable(self, "_on_SFX_Slider_value_changed"))

	AddResolutions()

func _on_Volume_Slider_value_changed(value):
	world.volume = -80 + -1. * value / 50. * (-80)
	world.asp.volume_db = world.volume

func _on_SFX_Slider_value_changed(value):
	world.volume_sfx = -80 + -1. * value / 50. * (-80)
	world.eye_audio.volume_db = world.volume_sfx
	world.eye_audio_2.volume_db = world.volume_sfx
	world.ending.volume_db = world.volume_sfx
	world.rewind_aud.volume_db = world.volume_sfx * 2
	world.no_rewind_aud.volume_db = world.volume_sfx * 2

func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return 20.0 * log(value) / log(10.0)

#script for resolution
@onready var ResOptionButton = $ResolutionChangeOption

var Resolutions: Dictionary = { "Fullscreen":Vector2(0, 0),
								"2560x1080":Vector2(2560, 1080),
								"1920x1080":Vector2(1920, 1080),
								"1024x768":Vector2(1024, 768),
								"1152x648":Vector2(1152, 648)}

func AddResolutions():
	for r in Resolutions:
		ResOptionButton.add_item(r)

func _on_resolution_change_option_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		await get_tree().process_frame
		center_window()

	var label = ResOptionButton.get_item_text(index)

	if Resolutions.has(label):
		DisplayServer.window_set_size(Resolutions[label])

func center_window():
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var new_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(new_position)
