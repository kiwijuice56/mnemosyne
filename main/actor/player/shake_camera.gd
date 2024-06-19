class_name ShakeCamera
extends Camera2D

var period:float = 0.1
var push: Vector2 
var dir: Vector2
var center: Vector2

func shake(magnitude):
	var initial_transform: Transform2D = self.transform # Store the full initial transform of the camera
	var elapsed_time: float = 0.0
	while elapsed_time < period:
		var offset = Vector2(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
		)
		self.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
		self.transform = initial_transform # Reset back to the original transform 

func _physics_process(delta: float) -> void:
	position = center + dir
	dir = lerp(dir, push, delta * 7)
	push = lerp(push, Vector2(), delta * 5)
