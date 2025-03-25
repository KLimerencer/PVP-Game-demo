extends AnimatedSprite2D
class_name PlantTemplate

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var area_2d: Area2D = $Area2D

var health
var cell:Cell
var is_right = false
var from_enemy = false
var is_end = false

func _ready() -> void:
	health_component.health_update.connect(_on_health_update)

func _finish_plant():
	health_component.health = health #如果不想要别的也同步finish plant的话 直接就在hand manager里给health component health 赋值

func set_right():
	is_right = true
	flip_h = true
	area_2d.scale.x = -1

func _on_health_update(health):
	if health <= 0:
		cell.is_plant = false
		queue_free()
		
func end_game():
	is_end = true
	self.stop()
