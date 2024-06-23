class_name Spear
extends Bullet

var gravity_vector: Vector2

func _physics_process(delta: float) -> void:
	if destroyed:
		return
	
	gravity_vector.y += 4 * delta
	velocity = dir.normalized() * speed + gravity_vector
	%SpriteHolder.rotation = Vector2(1, 0).angle_to(velocity.normalized())
	var collision: KinematicCollision2D = move_and_collide(velocity)
	if collision:
		if bounces >= bounce_amount:
			destroy()
		bounces += 1
		dir = dir.bounce(collision.get_normal())
		bounce()


func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	%AnimationPlayer.play("destroy")
	await %AnimationPlayer.animation_finished
	queue_free()
