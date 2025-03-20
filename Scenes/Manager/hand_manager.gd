extends Node2D

@export var Plants:Node2D
@export var cells:GridContainer
@export var cells2:GridContainer

var UINode:UI
var card_list:Array[CardTemplate]
var hand_scene:PlantTemplate
var card_res:cardRes
var path:String
var is_right:bool

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
		cell.cell_mouse_enter.connect(_on_cell_mouse_enter_right)
		cell.cell_mouse_exit.connect(_on_cell_mouse_exit)
	
func _on_card_click(card_res:cardRes):
	if not hand_scene:
		hand_scene = card_res.plant_scene.instantiate()
		hand_scene.health = card_res.max_health
		UINode.add_child(hand_scene)
		self.card_res = card_res
		self.path = card_res.plant_scene.resource_path
		
func _on_click_cell(cell:Cell):
	if hand_scene:
		AudioManager.play_plant()
		cell.is_plant = true
		hand_scene.global_position =  cell.global_position + card_res.card_shadow.get_size() / 2
		hand_scene.reparent(Plants)
		hand_scene.play("default")
		hand_scene._finish_plant()
		hand_scene.collision_shape.disabled = false
		hand_scene.cell = cell
		sync_plants.rpc(path, hand_scene.global_position,hand_scene.health, cell.get_path())
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
	var cell = get_node(cell_path)
	plant.cell = cell

func _on_cell_mouse_enter(cell:Cell):
	if hand_scene:
		cell.card_shadow.texture = card_res.card_shadow
	if is_right:
		is_right = false
		
func _on_cell_mouse_enter_right(cell:Cell):
	if hand_scene:
		cell.card_shadow.texture = card_res.card_shadow
	if not is_right:
		is_right = true

func _on_cell_mouse_exit(cell:Cell):
	cell.card_shadow.texture = null

func _process(delta: float) -> void:
	if hand_scene:
		hand_scene.position = get_global_mouse_position()
