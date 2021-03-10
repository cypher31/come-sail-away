extends KinematicBody2D

var my_turn : bool = false #check if it is the characters turn or not
var moving : bool = false #check if player is moving, can't attack while moving
var direction : Vector2 = Vector2(0,0)
var timer_attack #variable to hold the timers created to check for attack timing

onready var anim_player = $AnimationPlayer

const SPEED = 250

# need a signal to tell the character when it is their turn
func _ready():
	anim_player.set_current_animation("idle")
	anim_player.connect("animation_finished", self, "_anim_finished")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Movement handling
	if Input.is_action_pressed("north"):
		direction.x = 0
		direction.y = -1
		moving = true
	elif Input.is_action_pressed("south"):
		direction.x = 0
		direction.y = 1
		moving = true
	elif Input.is_action_pressed("east"):
		direction.x = 1
		direction.y = 0
		moving = true
	elif Input.is_action_pressed("west"):
		direction.x = -1
		direction.y = 0
		moving = true
	else:
		direction.x = 0
		direction.y = 0
		moving = false
		
	var velocity : Vector2 = direction * SPEED
	
	move_and_slide(velocity)
	
	#attack animations
	if !moving:
		if Input.is_action_just_pressed("attack_basic") and anim_player.get_current_animation() == "idle":
			anim_player.play("att_1")
		elif Input.is_action_just_pressed("attack_basic") and anim_player.get_current_animation() == "att_1":
			anim_player.play("att_2")
		elif !anim_player.is_playing():
			anim_player.play("idle")
	pass
	
func _anim_finished(animation):
	if !anim_player.is_playing():
		anim_player.play("idle")
	return
