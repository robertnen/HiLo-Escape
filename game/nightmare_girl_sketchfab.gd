extends Node3D

var anim_player
var speed = 2.0
var direction = -Vector3.LEFT

var time_elapsed = 0.0
var change_direction_time = 3.0
var stop_movement = 5.5

func _ready():
	anim_player = $AnimationPlayer

	anim_player.get_animation("Girl_Anim_Walk").loop = true
	anim_player.play("Girl_Anim_Walk")

func _process(delta):
	var world = get_parent().get_parent()

	if world.is_paused:
		anim_player.stop()
		return
		
	time_elapsed += delta

	translate(direction * speed * delta)

	# if character arrived in the middle of the hall and we want to turn right
	if time_elapsed >= change_direction_time:
		direction = Vector3.BACK

	# if character arrived to the table, stop the movement and animate idle state
	if time_elapsed >= stop_movement:
		direction = Vector3.ZERO
		anim_player.get_animation("Girl_Anim_Idle_1").loop = true
		anim_player.play("Girl_Anim_Idle_1")

# hand anime
func anime_hand():
	anim_player.play("Girl_Anim_Game_Over")
