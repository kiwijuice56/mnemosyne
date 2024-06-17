class_name Human
extends Actor

@export var fear_speed: float
@export var gravity: float = 128

var state: String = "idle"
var group: Array[Human]
var player: Player
var fear_spot: Vector2

func _ready() -> void:
	super._ready()
	%MoveTimer.start(randf_range(0.7, 3.5))
	%DetectionArea2D.body_entered.connect(_on_body_entered_detection)
	%DetectionArea2D.body_exited.connect(_on_body_exited_detection)
	%MoveTimer.timeout.connect(_on_idle_timeout)
	if randf() < 0.5:
		$SpriteHolder.scale.x *= -1

func _on_body_entered_detection(body: Node) -> void:
	if body is Player:
		player = body as Player
	
	if not body is Human:
		return
	var human: Human = body as Human
	if human.dead or human in group:
		return
	human.died.connect(_on_friend_died)
	group.append(human)

func _on_body_exited_detection(body: Node) -> void:
	if body is Player:
		player = null
	
	if not body is Human:
		return
	var human: Human = body as Human
	if human in group:
		human.died.disconnect(_on_friend_died)
		group.remove_at(group.find(human))

func _on_friend_died(global_death_position: Vector2) -> void:
	state = "scared"
	fear_spot = global_death_position

func _on_idle_timeout() -> void:
	if state == "idle":
		dir.x = (-1 if randf() < 0.5 else 1) if randf() < 0.5 else 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 8
	
	if state == "idle":
		if dir.x == 1 and (not %RightFloor.is_colliding() or %RightForward.is_colliding()):
			dir.x = 0
		if dir.x == -1 and (not %LeftFloor.is_colliding() or %LeftForward.is_colliding()):
			dir.x = 0
		velocity.x = dir.x * speed
	
	if state == "scared":
		dir.x = sign(global_position.x - fear_spot.x)
		if dir.x == 1 and %RightForward.is_colliding():
			dir.x = 0
		if dir.x == -1 and %LeftForward.is_colliding():
			dir.x = 0
		if fear_spot.distance_to(global_position) > 128.0:
			state = "idle" 
		velocity.x = dir.x * fear_speed
	
	velocity += knockback
	knockback = lerp(knockback, Vector2(), delta * accel * 0.75)
	
	if not locked:
		move_and_slide()

func kill() -> void:
	if dead:
		return
	died.emit(global_position)
	dead = true
	%AnimationPlayer.play("die")
	await %AnimationPlayer.animation_finished
	queue_free()

func initialize(_time: int) -> void:
	if randf() < 0.35:
		queue_free()
