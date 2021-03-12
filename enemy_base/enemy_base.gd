extends KinematicBody2D
#may use enemies to pass info to battle stage

#enemy stats
var health = 10
var armor = 0

onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#
#	pass

func _enemy_hit(attack_strength):
	if health > 0:
		var damage_calc = attack_strength - armor
		var damage_clamped = clamp(damage_calc, 1, damage_calc)
		
		health -= damage_clamped
		anim_player.play("hit")
		
		print("DAMAGE: " + str(damage_clamped))
		print("HEALTH LEFT: " + str(health))
		
		if health <= 0:
			queue_free()
	else:
		queue_free()
	return
