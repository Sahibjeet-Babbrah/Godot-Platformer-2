extends KinematicBody2D

onready var Player = get_parent().get_node("Player")

const GRAVITY = 20
const SPEED = 50
const UP = Vector2(0, -1)

# Declare member variables here.
var motion = Vector2()
var direction = -1
var movementTurnTimer = true
var point = 0.1
var direction2 = 0.0

var distanceVector = Vector2()
var distance = 0

#var bullet = preload("res://Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$TurnTimer.start()

#Function for attacking the Player
func _attack(var distanceVector = Vector2()):
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distanceVector = Player.position - position
	distance = sqrt((distanceVector.x * distanceVector.x) + (distanceVector.y * distanceVector.y))
	
	if direction == 1:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	
	motion.x = direction * SPEED
	
	motion = move_and_slide(motion, UP)
	
	if distance < 300:
		_attack(distanceVector)
	else:
		motion.y = 0

func _on_TurnTimer_timeout():
	direction = direction * -1
	$TurnTimer.start()