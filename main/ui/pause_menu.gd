class_name PauseMenu
extends PanelContainer

var can_pause: bool = true
var is_paused: bool = false

func _ready() -> void:
	%SfxSlider.value_changed.connect(_on_sfx_changed)
	%MusicSlider.value_changed.connect(_on_music_changed)
	%ShakeBox.toggled.connect(_on_shake_toggled)

func _input(event: InputEvent) -> void:
	if not can_pause:
		return
	if event.is_action_pressed("pause", false):
		is_paused = not is_paused
		update_ui()

func _on_sfx_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(1, val)

func _on_music_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(2, val - 3.8)

func _on_shake_toggled(toggled: bool) -> void:
	Ref.player.shake = toggled

func update_ui():
	visible = is_paused
	get_tree().paused = is_paused
