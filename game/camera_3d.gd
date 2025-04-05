extends Camera3D

var yaw: float = 0.0
var pitch: float = 0.0

const MIN_YAW = deg_to_rad(-120)
const MAX_YAW = deg_to_rad(60)

const MIN_PITCH = deg_to_rad(-40)
const MAX_PITCH = deg_to_rad(60)

func _ready():
	var rot = rotation
	yaw = rot.y
	pitch = rot.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var delta_yaw = -event.relative.x * 0.01
		var delta_pitch = -event.relative.y * 0.01

		var new_yaw = yaw + delta_yaw
		var new_pitch = pitch + delta_pitch

		if new_pitch < MIN_PITCH:
			new_pitch = MIN_PITCH
		elif new_pitch > MAX_PITCH:
			new_pitch = MAX_PITCH

		if new_yaw < MIN_YAW:
			new_yaw = MIN_YAW
		elif new_yaw > MAX_YAW:
			new_yaw = MAX_YAW

		yaw = new_yaw
		pitch = new_pitch
		rotation = Vector3(pitch, yaw, 0)
