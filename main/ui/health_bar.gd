class_name HealthBar
extends TextureProgressBar

func show_bar() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.8, 0.2)

func hide_bar() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
