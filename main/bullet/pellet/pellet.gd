class_name Pellet
extends Bullet

func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	$AnimationPlayer.play("destroy")
	await $AnimationPlayer.animation_finished
	queue_free()

func bounce() -> void:
	%ClangPlayer.play()
