extends Node
class_name ZombieManager

@onready var NORMAL_ZOMBIE = load("res://Scenes/Zombies/normal_zombie.tscn")
@export var Zombies:Node2D
@export var Zombies2:Node2D

var zombie_spawn_list:Array[Node2D]
var zombie_spawn_list2:Array[Node2D]
var zombie_list:Array[ZombieTemplate]
var zombie_list2:Array[ZombieTemplate]
var is_end := false
var spawn_over := false

func _ready() -> void:
	for zombieSpawn in Zombies.get_children():
		zombie_spawn_list.push_back(zombieSpawn)
	for zombieSpawn in Zombies2.get_children():
		zombie_spawn_list2.push_back(zombieSpawn)

#在之后游戏控制管理器进行调用
func start_game():
	spawn_zombie()

func end_game():
	is_end = true
	for zombie in zombie_list:
		zombie.is_end = true
	for zombie in zombie_list2:
		zombie.is_end = true

#创建僵尸
func spawn_zombie():
	AudioManager.play_zombie_first_coming()
	while not is_end:
		SpawnARandomZombie()
		await get_tree().create_timer(5).timeout
	
	#最后一波
	#AudioManager.play_last_wave()

#创建单个僵尸
func SpawnARandomZombie():
	var player = multiplayer.get_unique_id()
	var is_right = true if player != 1 else false
	if not is_end:
		var normal_zombie_scene:ZombieTemplate = NORMAL_ZOMBIE.instantiate()
		var random_index = randi_range(0,4)
		zombie_spawn_list[random_index].add_child(normal_zombie_scene)
		normal_zombie_scene.dead.connect(_on_zombie_dead)
		zombie_list.push_back(normal_zombie_scene)
		sync_zombie_spawn.rpc(random_index)

@rpc("any_peer","call_remote","reliable")
func sync_zombie_spawn(index):
	var normal_zombie_scene:ZombieTemplate = NORMAL_ZOMBIE.instantiate()
	zombie_spawn_list2[index].add_child(normal_zombie_scene)
	normal_zombie_scene.dead.connect(_on_zombie_dead)
	zombie_list2.push_back(normal_zombie_scene)
	normal_zombie_scene.set_right.call_deferred()

func _on_zombie_dead(zombie):
	zombie_list.erase(zombie)
	zombie_list2.erase(zombie)
