extends CanvasLayer

@onready var menu = $Menu
@onready var settings = $Settings
@onready var settings_button = $Menu/MarginContainer/VBoxContainer/SettingsButton
@onready var back_button = $Settings/Back_Button
@onready var exit_button = $Menu/MarginContainer/VBoxContainer/ExitButton

func _ready():
	settings.visible = false
	
	settings_button.connect("pressed", Callable(self, "_on_Settings_pressed"))
	back_button.connect("pressed", Callable(self, "_on_Back_pressed"))

	exit_button.connect("pressed", Callable(self, "_on_Exit_pressed"))

func _on_Settings_pressed():
	menu.visible = false
	settings.visible = true

func _on_Back_pressed():
	settings.visible = false
	menu.visible = true

func _on_Exit_pressed():
	get_tree().quit()
