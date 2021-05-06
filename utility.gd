extends Node
#global script for common methods and signals

#signals
signal turn_over #emitted when an entities turn is over
signal entity_hp_zero #emitted when an entities hp drops to zero
signal update_player_battle_menu #emitted when a turn change happens, updates menu for the characters turn
signal update_enemy_battle_menu
signal update_battle_time #updates the timer at the bottom of the battle screen
signal focus_on_me #for changing enemy focus
signal focus_off_me
signal focus_player_switch_on
signal focus_player_switch_off
signal remove_other_enemy_focus


#variables
var stage_current : String #hold what stage is currently used
var stage_main
var stage_battle = preload("res://stage_battle/stage_battle.tscn")

var dict_stages : Dictionary = {"stage_battle" : stage_battle}

var char_player = preload("res://main_char_prototype/main_char_prototype.tscn")

var dict_protagonist : Dictionary
var dict_party : Dictionary = {"char_player" : char_player, "side_1" : char_player, "side_2" : char_player, "side_3" : char_player}
var dict_battle : Dictionary = {}

var enemy_prototype = preload("res://enemy_base/enemy_base.tscn")

var dict_all_enemy : Dictionary = {
	"enemy_prototype" : {"instance" : enemy_prototype, "name" : "enemy_prototype", "WEAK_1" : "THUNDER", "WEAK_2" : "FIRE", "RESIST_1" : "WIND", "RESIST_2": "BEAST"},
	"RAVEN" : {"name" : "RAVEN", "WEAK_1" : "THUNDER", "WEAK_2" : "FIRE", "RESIST_1" : "WIND", "RESIST_2": "BEAST"}
	}

var dict_battle_enemies : Dictionary = {

	}


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.


func spawn_battle(party, enemies, stage):
	#PROTOTYPE ENEMY DICT
	dict_battle_enemies.enemy_0 = dict_all_enemy.enemy_prototype
	dict_battle_enemies.enemy_1 = dict_all_enemy.enemy_prototype
#	dict_battle_enemies.enemy_2 = dict_all_enemy.enemy_prototype
#	dict_battle_enemies.enemy_3 = dict_all_enemy.enemy_prototype
	#END PROTOTYPE ENEMY DICT
	
	var parent = stage_main.get_node("scene_curr").get_node("stage_battle")

	var parent_enemy : Container = parent.get_node("half_enemy")
	var parent_enemy_size = parent_enemy.get_rect().size
	var enemy_pos_offset = parent_enemy.get_rect().position
	var parent_characters : Container = parent.get_node("half_player")
	var parent_characters_size = parent_characters.get_rect().size
	
	var i : int = 0
	for character in party:
		var instance_to_spawn = party[character].instance()
		var spawn_area_center : Vector2 = parent_characters_size / 2
		var position : Vector2
		var pos_mod_x
		var pos_mod_y =  - 125 + i * 90
		
		if i % 2 == 0:
			pos_mod_x = 75
		else:
			pos_mod_x = 0
		
		position = Vector2(spawn_area_center.x + pos_mod_x, spawn_area_center.y + pos_mod_y)
		parent.all_battle_entities[i] = instance_to_spawn
		i += 1
		
		parent.all_players[i] = instance_to_spawn #store character in dictionary
		
		instance_to_spawn.position = position
		instance_to_spawn.in_battle = true
		parent_characters.add_child(instance_to_spawn)
		pass
		
	var j : int = 0
	for enemy in enemies:
		var instance_to_spawn = enemies[enemy]["instance"].instance()
		var spawn_area_center : Vector2 = parent_enemy_size / 2
		var position : Vector2
		var pos_mod_x
		var pos_mod_y =  - 125 + j * 90
		
		if j % 2 == 0:
			pos_mod_x = -75
		else:
			pos_mod_x = 0
		
		position = Vector2(spawn_area_center.x + pos_mod_x, spawn_area_center.y + pos_mod_y)
		parent.all_battle_entities[i+j] = instance_to_spawn
		j += 1
		
		parent.all_enemies[j] = instance_to_spawn #store enemy in dictionary
		
		instance_to_spawn.in_battle = true
		instance_to_spawn.enemy_type = enemies[enemy]["name"]
		instance_to_spawn.position = position
		parent_enemy.add_child(instance_to_spawn)
		pass
	
	parent._turn_manager()
	return
	
func stage_switch(stage_name):
	stage_current = stage_name
	
	var stage_parent = stage_main.get_node("scene_curr")
	var stage_curr = stage_parent.get_child(0)
	stage_curr.free()

	var stage_new = dict_stages[stage_name]
	var instance = stage_new.instance()
	stage_parent.add_child(instance)
	return
	
func stage_battle_switch(scene : String = "stage_battle"):
	stage_current = scene
	
	var stage_parent = stage_main.get_node("scene_curr")
	var stage_curr = stage_parent.get_child(0)
	stage_curr.queue_free()

	var stage_new = dict_stages[scene]
	var instance = stage_new.instance()
	stage_parent.add_child(instance)
	return
