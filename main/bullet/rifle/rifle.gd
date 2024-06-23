class_name Rifle
extends Bullet

func _ready() -> void:
	super._ready()
	flash_range = 5.0

func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	%AnimationPlayer.play("destroy")
	await %AnimationPlayer.animation_finished
	queue_free()
