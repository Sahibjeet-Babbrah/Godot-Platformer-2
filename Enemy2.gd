extends KinematicBody2D

const GRAVITY = 20
const SPEED = 50
const UP = Vector2(0, -1)
var motion = Vector2()
var distanceVector = Vector2()
var distance = 0
var dir = 0
var next_dir = 0
var next_dir_time = 0
const rect_time = 400
var next_jump_time = -1

var eye_reach = 90
var vision = 600


onready var Player = get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

#Function which sets the movement direction from the player
func set_dir(target_dir):
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + rect_time

#Function to check if the enemy can see the player
func sees_player():
	#Create the four eyes around the enemy
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	#Create the extent shapes around the player
	var player_pos = Player.get_global_position()
	var player_extents = Player.get_node("CollisionShape2D").shape.extents
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)
	
	var space_states = get_world_2d().direct_space_state
	
	#Check if the view is obstructed
	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for cornor in [top_left, top_right, bottom_left, bottom_right]:
			if (cornor - eye).length() > vision:
				continue
			var collision = space_states.intersect_ray(eye, cornor, [], 1)
			if collision and collision.collider.name == "Player":
				return true
	return false

func _process(delta):
	#Calculate the distance between the player and the enemy
	distanceVector = Player.position - position
	distance = sqrt((distanceVector.x * distanceVector.x) + (distanceVector.y * distanceVector.y))
	
	#If the distance if close move the enemy towards the player
	if distance < 300:
	#If the player is to the left
		if Player.position.x < position.x and next_dir != -1 and sees_player():
			set_dir(-1)
	#If the player is to the right
		elif Player.position.x > position.x and next_dir != 1 and sees_player():
			set_dir(1)
		#If the Player is at the same position
		elif Player.position.x == position.x and next_dir != 0:
			set_dir(0)
	
		if OS.get_ticks_msec() > next_dir_time:
			dir = next_dir
	
		if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
			#if abs(distanceVector.x) < 150:
			if Player.position.y < position.y - 64 and sees_player():
				motion.y = -800
			next_jump_time = -1
	
		if dir == -1:
			$AnimatedSprite.flip_h = true
		elif dir == 1:
			$AnimatedSprite.flip_h = false
		motion.x = dir * 100
	
		if Player.position.y < position.y - 64 and next_jump_time == -1 and is_on_floor():
			next_jump_time = OS.get_ticks_msec() + rect_time
	
	motion.y += GRAVITY
	
	motion = move_and_slide(motion, UP)
	
	pass
