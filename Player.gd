extends KinematicBody2D

#Set the constants for the movements
#UP declares the normal for the ship, telling when the player is on the floor
const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 500
const JUMP_HEIGHT = -600
var motion = Vector2()
var dead = false

#Function with the commands when the character dies
func dead():
	dead = true
	motion = Vector2(0, 0)
	#Create an dying and respawn animation
	$AnimatedSprite.play("Dead")
	$CollisionShape2D.disabled = true
	$respawn_timer.start()

#Function with the commands to move faster
func dash():
	if $AnimatedSprite.flip_h == true:
		motion.x = -1000
	else:
		motion.x = 1000

func _ready():
	position = get_tree().current_scene.get_node("StartPosition").position
	pass

#The function which processes all the physics calculations for a topic
func _physics_process(delta):
	
	if dead == false:
		var friction = false
		
		#Added gravity to the character, having the character accelerate downward at a speed
		#Of 10 pixels per second
		motion.y += GRAVITY
		#If the right key is pressed, move right
		if Input.is_action_pressed("ui_right"):
			motion.x = min(motion.x+ACCELERATION, MAX_SPEED)
			$AnimatedSprite.play("Walking")
			$AnimatedSprite.set_flip_h(false)
		#If the left key is pressed, move left
		elif Input.is_action_pressed("ui_left"):
			motion.x = max(motion.x-ACCELERATION, -MAX_SPEED)
			$AnimatedSprite.set_flip_h(true)
			$AnimatedSprite.play("Walking")
		#If the shift key is pressed, dash forward
		elif Input.is_action_just_pressed("ui_shift"):
			dash()
		elif Input.is_action_pressed("ui_down"):
			dead()
		
		#If no key is pressed then don't move from the character
		#And play the idle animation
		else:
			$AnimatedSprite.play("Standing")
			friction = true
		
		#If the player is on the floor, then intiate the jump or
		#Slow down the movement if 
		if is_on_floor():
			if Input.is_action_just_pressed("ui_up"):
				motion.y = JUMP_HEIGHT
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.2)
		else:
			#If the character is moving up, then play the up animation
			if motion.y < 0:
				$AnimatedSprite.play("Jumping")
			#Else play the falling animation
			else:
				$AnimatedSprite.play("Falling")
		#Function to move the actual character model
		motion = move_and_slide(motion, UP)
		
		#Counts the amount of collision
		if get_slide_count() > 0:
			#Loop through the amount of collisions
			for i in range(get_slide_count()):
				#If the enemy is touched
				if "Enemy" in get_slide_collision(i).collider.name:
					dead()
	#elif dead == true:
		#get_tree().reload_current_scene()

func _on_respawn_timer_timeout():
	get_tree().reload_current_scene()
