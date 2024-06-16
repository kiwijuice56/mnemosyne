extends Node

@onready var ui: CanvasLayer = get_tree().get_root().get_node("Main/UI")
@onready var hurt_effect: HurtEffect = ui.get_node("%HurtEffect")

