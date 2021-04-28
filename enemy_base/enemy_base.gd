extends KinematicBody2D
#may use enemies to pass info to battle stage

#signals
signal focus_on_me
signal focus_off_me

#enemy stats
var health : int = 10
var armor : int = 0
var speed : int = 5
var strength : int = 2
var dexterity : int = 2
var direction : Vector2 = Vector2(-1,0)
var moving : bool
var action_max : int = (speed + strength) * 2 + dexterity
var turn_active : bool = false #variable to check if it is this characters turn or not
var turn_count : int #variable to check what key this entity was given to remove from turn dict
var in_battle : bool #variablet to check if entity is in a battle or not
var enemy_type : String # the type of enemy this script is attached to

#battle stats
var health_points : int = health #health during battle
var action_points : int = 0 #always starts at zero
var turn_timer : Timer 
var char_class : String #character base clas
var class_base : String = "enemy"

var weakness : Dictionary = {
	"WEAK_1" : "",
	"WEAK_2" : "",
	"WEAK_3" : ""
}

var resist : Dictionary = {
	"RESIST_1" : "",
	"RESIST_2" : "",
	"RESIST_3" : ""
}

onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	#signals
	connect("focus_on_me", self, "_focus_on_me")
	connect("focus_off_me", self, "_focus_off_me")
	
	#turn time calc
	_new_timer()
	
	#set weakness & resists
	if enemy_type != null:
			if enemy_type == utility.dict_all_enemy.RAVEN.name:
				var enemy_info_root = utility.dict_all_enemy.RAVEN
				weakness.WEAK_1 = enemy_info_root.WEAK_1
				weakness.WEAK_2 = enemy_info_root.WEAK_2
				weakness.WEAK_3 = enemy_info_root.WEAK_3
				
				resist.RESIST_1 = enemy_info_root.RESIST_1
				resist.RESIST_2 = enemy_info_root.RESIST_2
				resist.RESIST_3 = enemy_info_root.RESIST_3
	pass # Replace with function body.

func _focus_on_me():
	$arrow_select.show()
	return

func _focus_off_me():
	$arrow_select.hide()
	return

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
	
func _update_battle_menu(battle_menu):
	
	return
