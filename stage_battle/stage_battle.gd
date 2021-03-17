extends Node2D

#scene that handles all aspects of the battle phase
var all_battle_entities : Dictionary
var dict_turn_order : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	utility.spawn_battle(utility.dict_party, utility.dict_battle_enemies, self)
	
	utility.connect("turn_over", self, "_next_turn")
	utility.connect("entity_hp_zero", self, "_remove_turn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _turn_manager(entities = all_battle_entities):
	#turn manager for active members of the battle
	
	#clear last round if any keys left over
	dict_turn_order.clear()
	
	#add all party members/enemies into entity dict 
	dict_turn_order = _calc_turns(entities)
		
	var first_turn = dict_turn_order[dict_turn_order.keys().min()]
	
	first_turn.turn_active = true
	first_turn.turn_count = dict_turn_order.keys().min()
	print("NEW TURN TIME")
	return
	
func _calc_turns(entities):
	var dict_turn_order_temp : Dictionary
	
	for unit in entities:
		if entities[unit] == null: #if unit has been killed skip number for turn calc
			continue
		
		if !entities[unit].is_in_group("enemy"):
			if entities[unit].fainted == true:
				continue
			
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
		curr_unit.turn_count = i
		
	return dict_turn_order_temp
	
func _next_turn(key, turn_dict = dict_turn_order):
	turn_dict.erase(key)
	
	if turn_dict.size() == 0:
		_turn_manager()
		return
	
	var next_turn = dict_turn_order[dict_turn_order.keys().min()]
	
	next_turn.turn_active = true
	return
	
func _remove_turn(entity_key):
	dict_turn_order.erase(entity_key)
	return
