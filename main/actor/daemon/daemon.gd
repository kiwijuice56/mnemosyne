class_name Daemon
extends Actor

@export var tentacle_speed: float = 16.0
@export var tentacle_material: ShaderMaterial

var tentacle_time: float
var target: Actor
var approach: float = 0

var potential_targets: Array[Actor]

func _ready() -> void:
	super._ready()
	
	%DetectionArea2D.body_entered.connect(_on_body_entered)
	%DetectionArea2D.body_exited.connect(_on_body_exited)
	
	%RetargetTimer.timeout.connect(retarget)
	
	tentacle_material = tentacle_material.duplicate()
	for child in %TentacleHolder.get_children():
		child.material = tentacle_material

func _on_body_entered(node: Node) -> void:
	if node in potential_targets or node.dead:
		return
	node.died.connect(_on_target_died.bind(node))
	potential_targets.append(node)
	retarget()

func _on_body_exited(node: Node) -> void:
	if node == target:
		target = null
	if node in potential_targets:
		node.died.disconnect(_on_target_died)
		potential_targets.remove_at(potential_targets.find(node))

func _on_target_died(_position: Vector2, actor: Actor) -> void:
	_on_body_exited(actor)

func _physics_process(delta: float) -> void:
	tentacle_time += tentacle_speed * delta
	tentacle_material.set_shader_parameter("s", tentacle_time)
	
	if is_instance_valid(target):
		var dist: float = (target.global_position - global_position).length() 
		approach = lerp(approach, dist - (64.0 if target is Player else 56.0), delta)
		approach = clamp(approach, -1, 1)
		dir = (target.global_position - global_position).normalized() * approach + Vector2(cos(tentacle_time * 0.2), sin(tentacle_time * 0.2)) * 0.36
	
	super._physics_process(delta)

func retarget() -> void:
	var dist: float = INF
	for actor in potential_targets:
		var test_dist: float = (actor.global_position - global_position).length()
		if test_dist < dist:
			dist = test_dist
			target = actor
