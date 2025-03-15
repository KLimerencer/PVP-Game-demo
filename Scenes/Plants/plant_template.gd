extends AnimatedSprite2D
class_name PlantTemplate

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent

var health
var cell:Cell

func _ready() -> void:
	health_component.health_update.connect(_on_health_update)

func _finish_plant():
	health_component.health = health #如果不想要别的也同步finish plant的话 直接就在hand manager里给health component health 赋值

func _on_health_update(health):
	if health <= 0:
		cell.is_plant = false
		queue_free()
