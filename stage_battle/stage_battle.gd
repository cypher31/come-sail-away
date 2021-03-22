extends Node2D

#scene that handles all aspects of the battle phase
var all_battle_entities : Dictionary
var dict_turn_order : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	utility.spawn_battle(utility.dict_party, utility.dict_battle_enemies, self)
	
	utility.connect("turn_over", self, "_next_turn")
	utility.connect("entity_hp_zero", self, "_remove_turn")
	utility.connect("update_battle_menu", self, "_update_battle_menu")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _turn_manager(entities = all_battle_entities):
	#turn manager for active members of the battle
	utility.connect("update_battle_menu", self, "_update_battle_menu")
	#clear last round if any keys left over
	dict_turn_order.clear()
	
	#add all party members/enemies into entity dict 
	dict_turn_order = _calc_turns(entities)
		
	var first_turn = dict_turn_order[dict_turn_order.keys().min()]
	
	first_turn.turn_active = true
	first_turn.turn_count = dict_turn_order.keys().min()
	utility.emit_signal("update_battle_menu", first_turn)
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
	
	next_turn.turn_active = true #active the next characters turn
	utility.emit_signal("update_battle_menu", next_turn) #update battle menu for next character
	return
	
func _remove_turn(entity_key):
	dict_turn_order.erase(entity_key)
	return

func _update_battle_menu(character):
	var battle_menu = $container_menu/menu_battle_player
	var menu_name : Label= battle_menu.get_node("PanelContainer/VBoxContainer/name")
	var bar_hp : ProgressBar = battle_menu.get_node("PanelContainer/VBoxContainer/hp_rs_container/bar_hp")
	var bar_hp_label : Label = bar_hp.get_node("Label")
	var bar_action : ProgressBar = battle_menu.get_node("PanelContainer/VBoxContainer/ap_lim_container/bar_action")
	var bar_action_label : Label = bar_action.get_node("Label")
	var bar_resource : ProgressBar = battle_menu.get_node("PanelContainer/VBoxContainer/hp_rs_container/bar_resource")
	var bar_resource_label : Label = bar_resource.get_node("Label")
	var bar_limit : ProgressBar = battle_menu.get_node("PanelContainer/VBoxContainer/ap_lim_container/bar_limit")
	var bar_limit_label : Label = bar_limit.get_node("Label")
	
	#character variables
	var char_class = character.class_base
	
	#set resource bar
	if char_class == "warrior":
		bar_resource.max_value = character.power_points_max
		bar_resource.set_value(character.power_points)
		var label_string_resource = "PP: %s/%s"
		var final_string_resource = label_string_resource % [character.power_points, character.power_points_max]
		bar_resource_label.set_text(final_string_resource)
	elif char_class == "defender":
		bar_resource.max_value = character.frenzy_points_max
		bar_resource.set_value(character.frenzy_points)
		var label_string_resource = "FP: %s/%s"
		var final_string_resource = label_string_resource % [character.frenzy_points, character.frenzy_points_max]
		bar_resource_label.set_text(final_string_resource)
	elif char_class == "hunter":
		bar_resource.max_value = character.dexterity_points_max
		bar_resource.set_value(character.dexterity_points)
		var label_string_resource = "DP: %s/%s"
		var final_string_resource = label_string_resource % [character.dexterity_points, character.dexterity_points_max]
		bar_resource_label.set_text(final_string_resource)
	elif char_class == "mage":
		bar_resource.max_value = character.magic_points_max
		bar_resource.set_value(character.magic_points)
		var label_string_resource = "MP: %s/%s"
		var final_string_resource = label_string_resource % [character.magic_points, character.magic_points_max]
		bar_resource_label.set_text(final_string_resource)
	
	#set name
#	menu_name.set_text(character.get_name())
	
	#set hp bar
	bar_hp.max_value = character.health
	bar_hp.set_value(character.health_points)
	var label_string_hp = "HP: %s/%s"
	var final_string_hp = label_string_hp % [character.health_points, character.health]
	bar_hp_label.set_text(final_string_hp)
	
	#set action bar
	bar_action.max_value = character.action_max
	bar_action.set_value(character.action_points)
	var label_string_action = "AP: %s/%s"
	var final_string_action = label_string_action % [character.action_points, character.action_max]
	bar_action_label.set_text(final_string_action)
	
	#set limit bar
	bar_limit.max_value = character.limit_points_max
	bar_limit.set_value(character.limit_points)
	var label_string_limit = "Limit: %s/%s"
	var final_string_limit = label_string_limit % [character.limit_points, character.limit_points_max]
	bar_limit_label.set_text(final_string_limit)
	return
