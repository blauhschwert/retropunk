extends Gun

func _fire(direction: Vector2, spawn_position) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = spawn_position
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet_damaga = bullet_damaga
	bullet.rotation = direction.angle()
	get_tree().root.add_child(bullet) 
