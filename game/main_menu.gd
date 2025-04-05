extends CanvasLayer

@onready var menu = $Menu
@onready var settings = $Settings
@onready var shadows_check = $Settings/CheckButton
@onready var settings_button = $Menu/MarginContainer/VBoxContainer/SettingsButton
@onready var back_button = $Settings/Back_Button
@onready var exit_button = $Menu/MarginContainer/VBoxContainer/ExitButton

func _ready():
	settings.visible = false
	
	settings_button.connect("pressed", Callable(self, "_on_Settings_pressed"))
	back_button.connect("pressed", Callable(self, "_on_Back_pressed"))

	exit_button.connect("pressed", Callable(self, "_on_Exit_pressed"))
	shadows_check.connect("toggled", Callable(self, "_on_shadows_check_toggled"))

func _on_Settings_pressed():
	menu.visible = false
	settings.visible = true

func _on_Back_pressed():
	settings.visible = false
	menu.visible = true

func _on_Exit_pressed():
	get_tree().quit()

func _add_lights_to_group(node):
	if node is Light3D:
		node.add_to_group("lights")
	for child in node.get_children():
		if child is Node:
			_add_lights_to_group(child)
			
func _on_shadows_check_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_enable_all_light_shadows()
	else:
		_disable_all_light_shadows()

func _disable_all_light_shadows():
	for light in get_tree().get_nodes_in_group("lights"):
		if light is Light3D:
			light.shadow_enabled = false
			
func _enable_all_light_shadows():
	for light in get_tree().get_nodes_in_group("lights"):
		if light is Light3D:
			light.shadow_enabled = true
