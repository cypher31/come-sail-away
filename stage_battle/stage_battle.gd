extends Node2D

#scene that handles all aspects of the battle phase
var all_battle_entities : Dictionary
var all_enemies : Dictionary
var all_players : Dictionary
var dict_turn_order : Dictionary

var curr_round : int = 1
var curr_enemy_focus : int = 1
var curr_player_focus : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	utility.spawn_battle(utility.dict_party, utility.dict_battle_enemies, self)
	
	utility.connect("turn_over", self, "_next_turn")
	utility.connect("entity_hp_zero", self, "_remove_turn")
	utility.connect("update_player_battle_menu", self, "_update_player_battle_menu")
	utility.connect("update_battle_time", self, "_update_battle_time")
	
	utility.connect("focus_on_me", self, "_focus_change_enemy")
#	utility.connect("focus_off_me", self, "_focus_change_enemy")
	
	utility.connect("focus_player_switch_on", self, "_focus_change_player")
	
	utility.connect("update_enemy_battle_menu", self, "_update_enemy_battle_menu")
	
	_focus_change_enemy(1) #set the default focus on a certain enemy
	pass # Replace with function body.

func _focus_change_player(tick):
	#count number of active party members
	var max_party_count : int
	for player in all_players:
		if all_players[player] != null:
			max_party_count += 1
		else:
			all_players.erase(player)
			
	var curr_key = curr_player_focus
	
	#check if this key is the current player; add extra tick if true
	var key_check  : int = curr_key + tick
	
	if key_check > all_players.size():
		key_check = all_players.keys().min()
	elif key_check == 0:
		key_check = all_players.keys().max()
		
	if all_players[key_check].turn_active:
		curr_key += tick
		print("skipped current player focus")
		all_players[curr_key - tick].emit_signal("focus_off_me") #need to handle this here when skipping current turn
	
#	if curr_key > all_players.size():
#		curr_key = all_players.keys().min()
#	if curr_key < 0:
#		curr_key = all_players.keys().max()
	
	if all_players.size() > 1:
		if tick == 1:
			if curr_key < max_party_count:
				all_players[curr_key].emit_signal("focus_off_me")
				all_players[curr_key + tick].emit_signal("focus_on_me")
				curr_key += tick
			else:
				curr_key = all_players.keys().min()
				all_players[all_players.keys().max()].emit_signal("focus_off_me")
				all_players[curr_key].emit_signal("focus_on_me")
		elif tick == -1:
			if curr_key > 1:
				all_players[curr_key].emit_signal("focus_off_me")
				all_players[curr_key + tick].emit_signal("focus_on_me")
				curr_key += tick
			else:
				curr_key = all_players.keys().max()
				all_players[all_players.keys().min()].emit_signal("focus_off_me")
				all_players[curr_key].emit_signal("focus_on_me")
	elif all_players.size() == 1:
		curr_key = all_players.keys().min()
		all_players[curr_key].emit_signal("focus_on_me")
	else:
		print("NO Players LEFT")
	
	curr_player_focus = curr_key
	return

func _focus_change_enemy(tick):
	#count number of active enemies
	var max_enemy_count : int
	for enemy in all_enemies:
		if all_enemies[enemy] != null:
			max_enemy_count += 1
		else:
			all_enemies.erase(enemy)
	
	var curr_key = curr_enemy_focus
	var new_key = curr_key + tick
	
	if all_enemies.size() > 1:
		if tick == 1:
			if new_key <= max_enemy_count:
				curr_key += tick
				all_enemies[curr_key - 1].emit_signal("focus_off_me")
				all_enemies[new_key].emit_signal("focus_on_me")
			else:
				curr_key = all_enemies.keys().min()
				all_enemies[all_enemies.keys().max()].emit_signal("focus_off_me")
				all_enemies[curr_key].emit_signal("focus_on_me")
		elif tick == -1:
			if new_key > 0:
				curr_key += tick
				all_enemies[curr_key + 1].emit_signal("focus_off_me")
				all_enemies[new_key].emit_signal("focus_on_me")
			else:
				curr_key = all_enemies.keys().max()
				all_enemies[all_enemies.keys().min()].emit_signal("focus_off_me")
				all_enemies[curr_key].emit_signal("focus_on_me")
	elif all_enemies.size() == 1:
		curr_key = all_enemies.keys().min()
		all_enemies[curr_key].emit_signal("focus_on_me")
	else:
		print("NO ENEMIES LEFT")
	
	curr_enemy_focus = curr_key
	return

func _turn_manager(entities = all_battle_entities):
	#turn manager for active members of the battle
	#clear last round if any keys left over
	dict_turn_order.clear()
	
	#add all party members/enemies into entity dict 
	dict_turn_order = _calc_turns(entities)
	
	var turn_cards : Dictionary = _get_turn_cards(dict_turn_order)
	
	var first_turn = dict_turn_order[dict_turn_order.keys().min()]
	
	first_turn.turn_active = true
	first_turn.turn_count = dict_turn_order.keys().min()
	first_turn.get_node("arrow_turn").show()
	
	_update_round_order_cards(turn_cards)
	
	#fill up party dict for focus change
	all_players.clear()
	var i : int = 1
	for entity in dict_turn_order:
		if !dict_turn_order[entity].is_in_group("enemy"):
			all_players[i] = dict_turn_order[entity]
			
			if dict_turn_order[entity].turn_active:
				curr_player_focus = i
			
			i += 1
	return
	
func _calc_turns(entities):
	var dict_turn_order_temp : Dictionary
	
	for unit in entities:
		if entities[unit] == null: #if unit has been killed skip number for turn calc
			continue
		
		if !entities[unit].is_in_group("enemy"):
			if entities[unit].fainted == true: #if a player unit has fainted, skip it
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

func _get_turn_cards(entities):
	var turn_card_order : Dictionary = {}
	var temp_dict = entities.duplicate()
#	for unit in entities:
#		if entities[unit] == null: #if unit has been killed skip
#			continue
#
#		if !entities[unit].is_in_group("enemy"):
#			if entities[unit].fainted == true: #if a player unit has fainted, skip it
#				continue

	for i in range(0, entities.size()):
		var id = temp_dict[temp_dict.keys().min()].get_instance_id()
		var curr_unit = instance_from_id(id)
		var turn_card : TextureRect = curr_unit.get_node("turn_card")
		
		turn_card_order[temp_dict.keys().min()] = turn_card
		temp_dict.erase(temp_dict.keys().min())
	return turn_card_order

func _update_round_order_cards(cards):
	var turn_card_container : HBoxContainer = $container_menu/container_menu_bot/container_round/hbox_round/scroll_turn_order/hbox_turn_order

	for card in cards:
		var texture = cards[card].get_texture()
		var texture_rect = TextureRect.new()
		texture_rect.set_texture(texture)
		texture_rect.set_name(str(card))
		turn_card_container.add_child(texture_rect)
	return
	
func _remove_turn_card(card_name):
	var turn_card_container : HBoxContainer = $container_menu/container_menu_bot/container_round/hbox_round/scroll_turn_order/hbox_turn_order
	
	if turn_card_container.has_node(str(card_name)):
		turn_card_container.get_node(str(card_name)).queue_free()
	return

func _next_turn(key, turn_dict = dict_turn_order):
	var curr_turn = dict_turn_order[dict_turn_order.keys().min()]
	curr_turn.get_node("arrow_turn").hide()
	#remove the card of the last entities turn
	_remove_turn_card(dict_turn_order.keys().min())
	
	turn_dict.erase(key)
	
	if turn_dict.size() == 0:
		_turn_manager()
		_round_update($container_menu/container_menu_bot/container_round/hbox_round/label_round_count)
		return
	
	var next_turn = dict_turn_order[dict_turn_order.keys().min()]
	
	next_turn.turn_active = true #activate the next characters turn
	next_turn.get_node("arrow_turn").show()
	
	if !next_turn.is_in_group("enemy"):
		utility.emit_signal("update_player_battle_menu", next_turn) #update battle menu for next character
		print("MENU UPDATED DJA;LKDFJA;")
#	else:
#		utility.emit_signal("update_enemy_battle_menu", next_turn) #probably only going to update enemy menu on player actions
	return
	
func _remove_turn(entity_key):
	dict_turn_order.erase(entity_key)
	_remove_turn_card(entity_key)
	return

func _round_update(round_label : Label):
	curr_round += 1
	var raw_string = "R%s"
	var new_string = raw_string % str(curr_round)
	round_label.set_text(new_string)
	return

func _update_player_battle_menu(character):
	var battle_menu = $container_menu/container_menu_bot/menu_battle_player
#	var menu_name : Label= battle_menu.get_node("PanelContainer/VBoxContainer/name")
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
	
	if char_class == "enemy":
		return
	
	#set limit bar
	bar_limit.max_value = character.limit_points_max
	bar_limit.set_value(character.limit_points)
	var label_string_limit = "Limit: %s/%s"
	var final_string_limit = label_string_limit % [character.limit_points, character.limit_points_max]
	bar_limit_label.set_text(final_string_limit)
	return

func _update_enemy_battle_menu(enemy_type, hp_max, hp_curr, weak, resist):
	var battle_menu = $container_menu/container_menu_bot/menu_battle_enemy
	var enemy_name : Label = battle_menu.get_node("PanelContainer/VBoxContainer/name_container/Label") 
	var hp_bar : ProgressBar = battle_menu.get_node("PanelContainer/VBoxContainer/hp_container/bar_hp")
	var hp_bar_label : Label = hp_bar.get_node("Label")
	var list_weak = $container_menu/container_menu_bot/menu_battle_enemy/PanelContainer/VBoxContainer/weak_resist_container/list_weakness
	var weak_1_label : Label = list_weak.get_node("Label1")
	var weak_2_label : Label = list_weak.get_node("Label2")
	var list_resist = $container_menu/container_menu_bot/menu_battle_enemy/PanelContainer/VBoxContainer/weak_resist_container/list_resist
	var resist_1_label : Label = list_resist.get_node("Label1")
	var resist_2_label : Label = list_resist.get_node("Label2")
	
	enemy_name.set_text(enemy_type)
	
	hp_bar.max_value = hp_max
	hp_bar.value = hp_curr
	var hp_bar_text : String = "HP: %s/%s"
	var hp_bar_text_fin : String = hp_bar_text % [str(hp_curr), str(hp_max)]
	hp_bar_label.set_text(hp_bar_text_fin)
	
	var text_weak1 = weak["WEAK_1"]
	var text_weak2 = weak["WEAK_2"]
	
	if text_weak1 == "null":
		text_weak1 = ""
		
	if text_weak2 == "null":
		text_weak2 = ""
		
	
	weak_1_label.set_text(text_weak1)
	weak_2_label.set_text(text_weak2)
	
	var text_resist1 = resist["RESIST_1"]
	var text_resist2 = resist["RESIST_2"]
	
	if text_resist1 == "null":
		text_resist1 = ""
		
	if text_resist2 == "null":
		text_resist2 = ""
		
	
	resist_1_label.set_text(text_resist1)
	resist_2_label.set_text(text_resist2)
	return

func _update_battle_time(time):
	var label_time_left : Label = $container_menu/container_menu_bot/container_round/mc_time/label_time_left
	label_time_left.set_text(str(time))
	
	var turn_curr = dict_turn_order[dict_turn_order.keys().min()]
	
	if !turn_curr.is_in_group("enemy"):
		utility.emit_signal("update_player_battle_menu", turn_curr)
#	else:
#		utility.emit_signal("update_enemy_battle_menu", turn_curr)
	return
	
func _change_enemy_focus():
	
	return
