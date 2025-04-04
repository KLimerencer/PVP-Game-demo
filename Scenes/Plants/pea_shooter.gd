extends PlantTemplate

@onready var attack_component: AttackComponent = $AttackComponent
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var marker: Marker2D = $Marker2D
const PEA_BULLET_SCENE = preload("res://Scenes/Bullet/pea_bullet.tscn")

func _finish_plant():
	health_component.health = health
	ray_cast.target_position.x = 800 - position.x

func set_right():
	is_right = true
	flip_h = true
	area_2d.scale.x = -1
	marker.position.x = -(marker.position.x)

func _process(delta: float) -> void:
	if ray_cast.get_collider() and not attack_component.can_attack and not self.is_end:
		attack_component.can_attack = true
	else:
		attack_component.can_attack = false

func _on_frame_changed() -> void:
	if animation == "attack" and frame == 11:
		var bullet:BulletTemplate = PEA_BULLET_SCENE.instantiate()
		bullet.global_position = marker.global_position
		if is_right:
			bullet.is_right = true
		get_parent().add_child(bullet)

func _on_animation_finished() -> void:
	if not attack_component.can_attack:
		play("default")
	if attack_component.can_attack:
		play("attack")
		AudioManager.play_shoot()
