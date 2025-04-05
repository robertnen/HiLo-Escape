extends Control

# script for audio settings
func _ready():
	$Volume_Slider.connect("value_changed", Callable(self, "_on_Volume_Slider_value_changed"))
	$SFX_Slider.connect("value_changed", Callable(self, "_on_SFX_Slider_value_changed"))

	# load resolutions in option button
	AddResolutions()

func _on_Volume_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_SFX_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return 20.0 * log(value) / log(10.0)

#script for resolution
@onready var ResOptionButton = $ResolutionChangeOption

var Resolutions: Dictionary = {"2560x1080":Vector2(2560, 1080),
								"1920x1080":Vector2(1920, 1080),
								"1024x768":Vector2(1024, 768),
								"1152x648":Vector2(1152, 648)}

func AddResolutions():
	for r in Resolutions:
		ResOptionButton.add_item(r)

func _on_resolution_change_option_item_selected(index: int) -> void:
	var label = ResOptionButton.get_item_text(index)
	if Resolutions.has(label):
		DisplayServer.window_set_size(Resolutions[label])
	else:
		pass
