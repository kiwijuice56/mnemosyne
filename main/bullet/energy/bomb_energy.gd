class_name BombEnergy
extends Energy


func shoot(shoot_dir: Vector2, velocity: Vector2, r: bool = true) -> void:
	var flash: Sprite2D = %Flash
	remove_child(flash)
	get_parent().add_child(flash)
	get_parent().move_child(flash, get_index())
	flash.global_position = global_position 
	
	dir = shoot_dir
	shooter_velocity = velocity
	
	if r:
		for i in range(6):
			var new_bullet: BombEnergy = self.duplicate()
			get_parent().add_child(new_bullet)
			get_parent().move_child(new_bullet, get_index())
			new_bullet.shooter = shooter
			new_bullet.shoot(shoot_dir.rotated((i + 1) * 2 * PI / 7.0), velocity, false)
