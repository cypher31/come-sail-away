extends KinematicBody2D

#signals
signal focus_on_me
signal focus_off_me

#char variables
var my_turn : bool = false #check if it is the characters turn or not
var moving : bool = false #check if player is moving, can't attack while moving
var direction : Vector2 = Vector2(0,0)
var fainted : bool #check if unit has lost all HP and needs revive
var timer_attack #variable to hold the timers created to check for attack timing
var turn_active : bool #variable to check if it is this characters turn or not
var turn_count : int #variable to check what key this entity was given to remove from turn dict
var in_battle : bool = false #variable to check if entity is in a battle
var size_height #for capsule
var size_width #for capsule

#character stats
var health : int = 25
var power : int  = 2 #power, dex, frenzy, and magic are assigned based on character class
var dexterity : int = 2
var frenzy : int = 2
var magic : int = 2
var defense : int = 2
var strength : int = 2 #character strength - used for damage calc
var speed : int = 5 #character speed - used for turn time calc
var action_max : int = (speed + strength) * 2 + dexterity
var power_points_max : int = power * 4
var magic_points_max : int = magic * 4
var frenzy_points_max : int = frenzy * 4
var dexterity_points_max : int = dexterity * 4
export var class_base : String = "warrior" #4 base classes warrior, defender, hunter, mage

#battle stats
var health_points : int = health #health during battle
var action_points : int = 0 #always starts at zero
var magic_points : int = magic_points_max
var frenzy_points : int = frenzy_points_max
var dexterity_points : int = dexterity_points_max
var power_points : int = power_points_max
var limit_points : float #limit points during battle
var limit_points_max : float = 100 #max number is always 100
var turn_timer : Timer 
var char_class : String #character base clas

onready var anim_player = $AnimationPlayer

# need a signal to tell the character when it is their turn
func _ready():
	anim_player.set_current_animation("idle")
	anim_player.connect("animation_finished", self, "_anim_finished")
	
	#turn time calc
	_new_timer()
	
	#connections
	$area2d_att_1.connect("body_entered", self, "_attack_collision")
	$area2d_att_2.connect("body_entered", self, "_attack_collision")
	
	connect("focus_on_me", self, "_focus_on_me")
	connect("focus_off_me", self, "_focus_off_me")
	
	#get size of character
	size_height = $CollisionShape2D.get_shape().height #for capsule
	size_width = $CollisionShape2D.get_shape().radius #for capsule
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !turn_active:
		turn_timer.set_paused(true)
	else:
		turn_timer.set_paused(false)
	
	var time_left = turn_timer.get_time_left()
	
	#movement handling out of battle
	if !in_battle:
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
		
	# Movement handling in battle
	if time_left > 0.01 and turn_active and in_battle:
		var stage_bound_north = (position.y - size_height / 2) > 0
		var stage_bound_south = (position.y + size_height / 2) < 400
		var stage_bound_west = (position.x - size_width) > 0
		var stage_bound_east = (position.x + size_width / 2) < 960
		
		if Input.is_action_pressed("north") and stage_bound_north:
			direction.x = 0
			direction.y = -1
			moving = true
			turn_timer.set_paused(false)
		elif Input.is_action_pressed("south") and stage_bound_south:
			direction.x = 0
			direction.y = 1
			moving = true
			turn_timer.set_paused(false)
		elif Input.is_action_pressed("east") and stage_bound_east:
			direction.x = 1
			direction.y = 0
			moving = true
			turn_timer.set_paused(false)
		elif Input.is_action_pressed("west") and stage_bound_west:
			direction.x = -1
			direction.y = 0
			moving = true
			turn_timer.set_paused(false)
		else:
			direction.x = 0
			direction.y = 0
			moving = false
			turn_timer.set_paused(true)
	
	var velocity : Vector2 = direction * speed
	
	var collision : KinematicCollision2D = move_and_collide(velocity)
		
	#attack animations - only work if enough time is left on timer
	if turn_active and in_battle:
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
			
			if Input.is_action_just_pressed("focus_change_enemy_up"):
				utility.emit_signal("focus_on_me", 1)
				pass
			elif Input.is_action_just_pressed("focus_change_enemy_down"):
				utility.emit_signal("focus_on_me", -1)
				
			if Input.is_action_just_pressed("focus_change_player_up"):
				utility.emit_signal("focus_player_switch_on", 1)
			elif Input.is_action_just_pressed("focus_change_player_down"):
				utility.emit_signal("focus_player_switch_on", -1)

	#turn handling - 
	if !turn_timer.paused:
		var time_to_show = time_left
		var format_time = "%3.2f" % time_left
		utility.emit_signal("update_battle_time", format_time)
		pass
	
	if time_left <= 0.01 and in_battle:
		direction.x = 0
		direction.y = 0
		moving = false
		turn_timer.set_paused(true)
		_next_turn()
		pass
		
	if !utility.stage_current == "stage_battle":
		turn_timer.set_paused(true)
		pass
		
	#collision handling
	if collision and !utility.stage_current == "stage_battle":
		var object = collision.collider
		print("COLLIDINE")
		if object.is_in_group("enemy"):
			utility.stage_battle_switch()
		pass
	pass
	
func _anim_finished(animation):
	if !anim_player.is_playing():
		anim_player.play("idle")
	return

func _attack_collision(body):
	if body.is_in_group("enemy"):
		body._enemy_hit(strength)
		_limit_calc_attack(strength)
		pass
	return
	
func _next_turn():
	#reset timer
	_new_timer()
	
	turn_active = false
	utility.emit_signal("turn_over", turn_count)
	return
	
	
func _new_timer():
	var turn_time : float = 4.0 + speed / 10.0
	
	turn_timer = Timer.new()
	turn_timer.set_wait_time(turn_time)
	turn_timer.set_one_shot(true)
	add_child(turn_timer)
	
	if in_battle:
		turn_timer.start()
		
	set_physics_process(true)
	return
	
func _limit_calc_attack(strength):
	limit_points += float(strength) / 4.0
	utility.emit_signal("update_player_battle_menu", self)
	return
	
func _limit_calc_defend(damage):
	
	return
	
func _focus_on_me():
	$arrow_select.show()
	return

func _focus_off_me():
	$arrow_select.hide()
	return
