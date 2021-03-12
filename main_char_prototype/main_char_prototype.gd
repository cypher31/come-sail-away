extends KinematicBody2D

var my_turn : bool = false #check if it is the characters turn or not
var moving : bool = false #check if player is moving, can't attack while moving
var direction : Vector2 = Vector2(0,0)
var timer_attack #variable to hold the timers created to check for attack timing

#character stats
var health : int = 25
var defense : int = 2
var strength : int = 2 #character strength - used for damage calc
var speed : int = 2 #character speed - used for turn time calc
var turn_timer : Timer 

onready var anim_player = $AnimationPlayer

const SPEED = 5

# need a signal to tell the character when it is their turn
func _ready():
	anim_player.set_current_animation("idle")
	anim_player.connect("animation_finished", self, "_anim_finished")
	
	#turn time calc
	var turn_time : float = 4.0 + speed / 10.0
	
	turn_timer = Timer.new()
	turn_timer.set_wait_time(turn_time)
	turn_timer.set_one_shot(true)
	add_child(turn_timer)
	turn_timer.start()
	
	#connections
	$area2d_att_1.connect("body_entered", self, "_attack_collision")
	$area2d_att_2.connect("body_entered", self, "_attack_collision")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var time_left = turn_timer.get_time_left()
	# Movement handling
	if time_left > 0.01:
		if Input.is_action_pressed("north"):
			direction.x = 0
			direction.y = -1
			moving = true
			turn_timer.set_paused(false)
		elif Input.is_action_pressed("south"):
			direction.x = 0
			direction.y = 1
			moving = true
			turn_timer.set_paused(false)
		elif Input.is_action_pressed("east"):
			direction.x = 1
			direction.y = 0
			moving = true
			turn_timer.set_paused(false)
		elif Input.is_action_pressed("west"):
			direction.x = -1
			direction.y = 0
			moving = true
			turn_timer.set_paused(false)
		else:
			direction.x = 0
			direction.y = 0
			moving = false
			turn_timer.set_paused(true)
	else:
			#end turn here
			direction.x = 0
			direction.y = 0
			moving = false
			turn_timer.set_paused(true)
		
	var velocity : Vector2 = direction * SPEED
	
	var collision : KinematicCollision2D = move_and_collide(velocity)
	
	#attack animations - only work if enough time is left on timer
	if !moving and time_left > 0.01:
		if Input.is_action_just_pressed("attack_basic") and anim_player.get_current_animation() == "idle":
			anim_player.play("att_1")
			var wait_time = turn_timer.get_time_left()
			var new_time : float = wait_time - 0.25
			
			if new_time <= 0:
				new_time = 0.01
			
			turn_timer.set_paused(false)
			turn_timer.set_wait_time(new_time)
			turn_timer.start()
		elif Input.is_action_just_pressed("attack_basic") and anim_player.get_current_animation() == "att_1":
			anim_player.play("att_2")
			var wait_time = turn_timer.get_time_left()
			var new_time : float = wait_time - 0.25
			
			if new_time <= 0:
				new_time = 0.01
			
			turn_timer.set_paused(false)
			turn_timer.set_wait_time(new_time)
			turn_timer.start()
		elif !anim_player.is_playing():
			anim_player.play("idle")
			turn_timer.set_paused(true)
			pass
			
	
	#turn handling - 
	if !turn_timer.paused:
		print(turn_timer.get_time_left())
	
	if time_left <= 0.01:
		print("TURN OVER")
	
	#collision handling
	if collision and !utility.stage_current == "stage_battle":
		var object = collision.collider
		print("COLLIDINE")
		if object.is_in_group("enemy"):
			utility.stage_switch("stage_battle")
		pass
	pass
	
func _anim_finished(animation):
	if !anim_player.is_playing():
		anim_player.play("idle")
	return

func _attack_collision(body):
	if body.is_in_group("enemy"):
		body._enemy_hit(strength)
		print("HIT!")
		pass
	return
