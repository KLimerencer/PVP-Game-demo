extends Node
class_name ZombieManager

@onready var NORMAL_ZOMBIE = load("res://Scenes/Zombies/normal_zombie.tscn")
@export var Zombies:Node2D
@export var Zombies2:Node2D

signal game_success

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
	for i in range(2):
		SpawnARandomZombie(false)
		SpawnARandomZombie(true)
		await get_tree().create_timer(1).timeout
		
	await get_tree().create_timer(5).timeout

	for i in range(3):
		SpawnARandomZombie(false)
		SpawnARandomZombie(true)
		await get_tree().create_timer(1).timeout
		
	await get_tree().create_timer(5).timeout
	
	#最后一波
	AudioManager.play_last_wave()
	for i in range(5):
		SpawnARandomZombie(false)
		SpawnARandomZombie(true)
		await get_tree().create_timer(1).timeout
		
	spawn_over = true

#创建单个僵尸
func SpawnARandomZombie(right:bool):
	if not right:
		if not is_end:
			var normal_zombie_scene:ZombieTemplate = NORMAL_ZOMBIE.instantiate()
			var random_index = randi_range(0,4)
			zombie_spawn_list[random_index].add_child(normal_zombie_scene)
			normal_zombie_scene.dead.connect(_on_zombie_dead)
			zombie_list.push_back(normal_zombie_scene)
			sync_zombie_spawn.rpc(random_index, false)
	if right:
		if not is_end:
			var normal_zombie_scene:ZombieTemplate = NORMAL_ZOMBIE.instantiate()
			var random_index = randi_range(0,4)
			zombie_spawn_list2[random_index].add_child(normal_zombie_scene)
			normal_zombie_scene.dead.connect(_on_zombie_dead)
			zombie_list2.push_back(normal_zombie_scene)
			normal_zombie_scene.set_right()
			sync_zombie_spawn.rpc(random_index, true)

@rpc("any_peer","call_remote","reliable")
func sync_zombie_spawn(index,is_right):
	var normal_zombie_scene:ZombieTemplate = NORMAL_ZOMBIE.instantiate()
	zombie_spawn_list[index].add_child(normal_zombie_scene)
	normal_zombie_scene.dead.connect(_on_zombie_dead)
	zombie_list.push_back(normal_zombie_scene)
	if is_right:
		normal_zombie_scene.set_right.call_deferred()

func _on_zombie_dead(zombie):
	zombie_list.erase(zombie)
	if len(zombie_list) == 0 and spawn_over:
		game_success.emit()
