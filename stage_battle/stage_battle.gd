extends Node2D

#scene that handles all aspects of the battle phase
var all_battle_entities : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	utility.spawn_battle(utility.dict_party, utility.dict_battle_enemies, self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _turn_manager(entities = all_battle_entities):
	#turn manager for active members of the battle
	
	#add all party members/enemies into entity dict 
	var dict_turn_order = _calc_turns(entities)
		
	var first_turn = dict_turn_order[dict_turn_order.keys().min()].get_name()
	print(first_turn)
	return
	
func _calc_turns(entities):
	var dict_turn_order_temp : Dictionary
	
	for unit in entities:
		var id = entities[unit].get_instance_id()
		var curr_unit = instance_from_id(id)
		var unit_speed : int = curr_unit.speed
		var CT : float = 0.0
		
		var i : int = 0
		while CT < 100:
			var rand_speed = rand_range(unit_speed, unit_speed * 4)
			CT += rand_speed
			i += 1
		print(i)
		while dict_turn_order_temp.has(i):
			i += 1
			
		dict_turn_order_temp[i] = curr_unit
		
	return dict_turn_order_temp
