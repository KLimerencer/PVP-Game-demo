extends Node2D

@export var Plants:Node2D
@export var cells:GridContainer
@export var cells2:GridContainer

var UINode:UI
var card_list:Array[CardTemplate]
var hand_scene:PlantTemplate
var card_res:cardRes
var path:String
var plant_enemy = false

func _ready() -> void:
	UINode = get_tree().get_first_node_in_group("UI")
	card_list = UINode.card_list
	for card in card_list:
		card.card_click.connect(_on_card_click)
	for cell in cells.get_children():
		cell.click_cell.connect(_on_click_cell)
		cell.cell_mouse_enter.connect(_on_cell_mouse_enter)
		cell.cell_mouse_exit.connect(_on_cell_mouse_exit)
	for cell in cells2.get_children():
		cell.click_cell.connect(_on_click_cell)
		cell.cell_mouse_exit.connect(_on_cell_mouse_exit)

func _on_card_click(card_res:cardRes):
	if not hand_scene:
		hand_scene = card_res.plant_scene.instantiate()
		hand_scene.health = card_res.max_health
		UINode.add_child(hand_scene)
		self.card_res = card_res
		self.path = card_res.plant_scene.resource_path
	else:
		UINode.remove_child(hand_scene)
		hand_scene.queue_free()
		hand_scene = null
		hand_scene = card_res.plant_scene.instantiate()
		hand_scene.health = card_res.max_health
		UINode.add_child(hand_scene)
		self.card_res = card_res
		self.path = card_res.plant_scene.resource_path
		
func _on_click_cell(cell:Cell):
	if hand_scene and ((cell.get_parent() == cells2 and plant_enemy == true) or cell.get_parent() == cells):
		AudioManager.play_plant()
		cell.is_plant = true
		hand_scene.global_position =  cell.global_position + card_res.card_shadow.get_size() / 2
		hand_scene.reparent(Plants)
		hand_scene.play("default")
		hand_scene._finish_plant()
		hand_scene.collision_shape.disabled = false
		hand_scene.cell = cell
		var cell2_path = '/root/Menu/level/level1/UI/Cells2/'+  str(cell.get_path()).split('/')[-1]
		var cell2 = get_node(NodePath(cell2_path))
		var position = cell2.global_position + card_res.card_shadow.get_size() / 2
		sync_plants.rpc(path, position,hand_scene.health, cell2_path)
		print(cell.get_path())
		for card in card_list:
			if card.card_res.card_type == card_res.card_type:
				card.is_plant = true
				card.card_plant.emit(card.card_res.sun_num)
				break
		
		cell.card_shadow.texture = null
		hand_scene = null
		card_res = null
		
@rpc("any_peer","call_remote","reliable")
func sync_plants(plant_scene_path: String, position: Vector2, health, cell_path):
	var plant_scene = load(plant_scene_path)
	var plant = plant_scene.instantiate()
	plant.health = health
	plant.position = position  # 设定位置
	Plants.add_child(plant)
	plant.play("default")
	plant._finish_plant()
	plant.collision_shape.disabled = false
	plant.set_right()
	var cell = get_node(cell_path)
	plant.cell = cell
	plant.from_enemy = true

func _on_cell_mouse_enter(cell:Cell):
	if hand_scene:
		if cell.get_parent() == cells2 and plant_enemy == true or cell.get_parent() == cells:
			cell.card_shadow.texture = card_res.card_shadow

func _on_cell_mouse_exit(cell:Cell):
	cell.card_shadow.texture = null

func _process(delta: float) -> void:
	if hand_scene:
		hand_scene.position = get_global_mouse_position()
