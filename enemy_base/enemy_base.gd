extends KinematicBody2D
#may use enemies to pass info to battle stage

#enemy stats
var health : int = 10
var health_points : int = health
var armor = 0
var speed = 5
var direction : Vector2 = Vector2(-1,0)
var moving : bool
var turn_timer : Timer
var turn_active : bool = false #variable to check if it is this characters turn or not
var turn_count : int #variable to check what key this entity was given to remove from turn dict
var in_battle : bool #variablet to check if entity is in a battle or not

onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	#turn time calc
	_new_timer()
	pass # Replace with function body.


func _physics_process(delta):
	if !turn_active:
		turn_timer.set_paused(true)
	else:
		turn_timer.set_paused(false)
		
	var time_left = turn_timer.get_time_left()
	
	if turn_active:
		turn_timer.set_paused(false)
		direction = Vector2(-1,0)
		var velocity : Vector2 = speed * direction
		move_and_collide(velocity)
	else:
		direction = Vector2(0,0)
		pass
		
	#turn handling - 
	if !turn_timer.paused:
		print(turn_timer.get_time_left())
		pass
	
	if time_left <= 0.01 and in_battle:
		direction.x = 0
		direction.y = 0
		moving = false
		turn_timer.set_paused(true)
		_next_turn()
		pass
	return

func _enemy_hit(attack_strength):
	if health_points > 0:
		var damage_calc = attack_strength - armor
		var damage_clamped = clamp(damage_calc, 1, damage_calc)
		
		health_points -= damage_clamped
		anim_player.play("hit")
		
		print("DAMAGE: " + str(damage_clamped))
		print("HEALTH LEFT: " + str(health_points))
		
		if health_points <= 0:
			queue_free()
			utility.emit_signal("entity_hp_zero", turn_count)
	else:
		queue_free()
		utility.emit_signal("entity_hp_zero", turn_count)
	return
	
func _next_turn():
	#reset timer
	set_physics_process(false)
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
