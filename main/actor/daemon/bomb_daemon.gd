class_name BombDaemon
extends Daemon

func _ready() -> void:
	super._ready()
	primary_bullet_scene = preload("res://main/bullet/energy/bomb_energy.tscn")
