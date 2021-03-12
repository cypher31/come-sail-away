extends Node
#global script for common methods and signals
var stage_current : String #hold what stage is currently used
var stage_main
var stage_battle = preload("res://stage_battle/stage_battle.tscn")

var dict_stages : Dictionary = {"stage_battle" : stage_battle}

var char_player = preload("res://main_char_prototype/main_char_prototype.tscn")

var dict_protagonist : Dictionary
var dict_party : Dictionary = {"char_player" : char_player}
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
	
	var parent = stage_main.get_node("scene_curr")
	var stage_to_instance = stage
	var instance = stage_to_instance.instance()
	
	parent.add_child(instance)
	
	var parent_enemy : Container = instance.get_node("half_enemy")
	var parent_enemy_size = parent_enemy.get_rect().size
	var enemy_pos_offset = parent_enemy.get_rect().position
	var parent_characters : Container = instance.get_node("half_player")
	var parent_characters_size = parent_characters.get_rect().size
	
	print(parent)
	print(parent_enemy.get_name())
	print(parent_enemy_size)
	print(enemy_pos_offset)
	print(parent_characters.get_name())
	print(parent_characters_size)
	return
	
func stage_switch(stage_name):
	stage_current = stage_name
	
	var stage_parent = stage_main.get_node("scene_curr")
	var stage_curr = stage_parent.get_child(0)
	stage_curr.queue_free()
	
	var stage_new = dict_stages[stage_name]
	var instance = stage_new.instance()
	stage_parent.add_child(instance)
	return
