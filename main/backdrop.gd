class_name Backdrop
extends Sprite2D

@export var old_image: Texture
@export var mid_image: Texture
@export var new_image: Texture

func reset():
	pass

func initialize(time: int) -> void:
	if time <= 2:
		texture = old_image
	elif time <= 4:
		texture = mid_image
	else:
		texture = new_image
