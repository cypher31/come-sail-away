extends Node
#global script for common methods and signals
var stage_current : String #hold what stage is currently used
var stage_main
var stage_battle = preload("res://stage_battle/stage_battle.tscn")

var dict_stages : Dictionary = {"stage_battle" : stage_battle}

var char_player = preload("res://main_char_prototype/main_char_prototype.tscn")

var dict_protagonist : Dictionary
var dict_party : Dictionary = {"char_player" : char_player, "side_1" : char_player, "side_2" : char_player, "side_3" : char_player}
var dict_battle : Dictionary = {}

var enemy_prototype = preload("res://enemy_base/enemy_base.tscn")

var dict_all_enemy : Dictionary = {"enemy_prototype" : enemy_prototype}

var dict_battle_enemies : Dictionary = {
	"enemy_0" : null,
	"enemy_1" : null,
	"enemy_2" : null,
	"enemy_3" : null,
	"enemy_4" : null,
	"enemy_5" : null,
	"enemy_6" : null,
	"enemy_7" : null,
	"enemy_8" : null,
	"enemy_9" : null,
	}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_battle(party, enemies, stage):
	#PROTOTYPE ENEMY DICT
	dict_battle_enemies.enemy_0 = dict_all_enemy.enemy_prototype
	dict_battle_enemies.enemy_1 = dict_all_enemy.enemy_prototype
	dict_battle_enemies.enemy_2 = dict_all_enemy.enemy_prototype
	dict_battle_enemies.enemy_3 = dict_all_enemy.enemy_prototype
	dict_battle_enemies.enemy_4 = dict_all_enemy.enemy_prototype
	#END PROTOTYPE ENEMY DICT
	
	var parent = stage_main.get_node("scene_curr").get_node("stage_battle")

	var parent_enemy : Container = parent.get_node("half_enemy")
	var parent_enemy_size = parent_enemy.get_rect().size
	var enemy_pos_offset = parent_enemy.get_rect().position
	var parent_characters : Container = parent.get_node("half_player")
	var parent_characters_size = parent_characters.get_rect().size
	
	var i : int = 0
	for character in dict_party:
		var instance_to_spawn = dict_party[character].instance()
		var spawn_area_center : Vector2 = parent_characters_size / 2
		var position : Vector2
		var pos_mod_x
		var pos_mod_y =  - 150 + i * 100
		
		if i % 2 == 0:
			pos_mod_x = 75
		else:
			pos_mod_x = 0
		
		position = Vector2(spawn_area_center.x + pos_mod_x, spawn_area_center.y + pos_mod_y)
		
		i += 1
		
		parent_characters.add_child(instance_to_spawn)
		instance_to_spawn.position = position  
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
