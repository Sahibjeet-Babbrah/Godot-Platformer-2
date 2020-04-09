extends KinematicBody2D

#Constants used for the calculations
const GRAVITY = 20
const SPEED = 50
const MAX_SPEED = 200
const UP = Vector2(0, -1)
const ACCELERATION = 50

#The Vectors for the movement speeds of the enemy
var motion = Vector2()
var turnAbility = true

#Variable for the direction vector
var direction = 1

#Get the information on the player in the parent node
onready var Player = get_parent().get_node("Player")
var distance_Vector = Vector2()
var distance = 0.0

#Process function
func _process(delta):
	distance_Vector = Player.position - position
	distance = sqrt((distance_Vector.x * distance_Vector.x) + (distance_Vector.y * distance_Vector.y))
	
	#Flip the sprite based on the movement direction
	if direction == 1:
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
	
	#Play the walking animation
	$AnimatedSprite.play("Walking")
	
	#Add a gravity to the enemy
	motion.y += GRAVITY
	
	#Changing the direction of the player
	if direction == 1:
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
	elif direction == -1:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
	
	#if distance < 300 and dashAbility == true:
		#dash()
	
	#If the enemy is on a wall then turn around
	if is_on_wall() and turnAbility == true:
		direction = direction * -1
		$RayCast2D.position.x *= -1
		turnAbility = false
		$TurnTimer.start()
	
	#If the enemy reachs the edge of a ledge, turn around
	if $RayCast2D.is_colliding() == false:
		direction = direction * -1
		$RayCast2D.position.x *= -1
	
	#Move and slide to move the enemy
	motion = move_and_slide(motion, UP)

#Function to allow for turning again
func _on_TurnTimer_timeout():
	turnAbility = true