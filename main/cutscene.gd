class_name Cutscene
extends PanelContainer

var message_text: String 
var pause_indices: Dictionary = {}
var chars_per_second: float = 32.0
var character_progress: float
var pause_progress: float
var characters_advanced: int
var is_progressing: bool = false
var is_pausing: bool = false
var is_odd: bool = false
var is_sped_up: bool = false
var i_can_skip: bool = true

const SPEED_UP_MULT: float = 7.0

signal finished_progressing
signal continued

func _ready() -> void:
	modulate.a = 1.0
	%Text.visible_characters = 0
	%Skip.visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if i_can_skip and event.is_pressed():
		%Skip.visible = true

func _input(event: InputEvent) -> void:
	if %Skip.visible and event.is_action_pressed("skip"):
		is_sped_up = true
	if event.is_action_released("skip"):
		is_sped_up = false

func _physics_process(delta: float) -> void:
	if is_pausing:
		pause_progress -= chars_per_second * delta * (SPEED_UP_MULT if is_sped_up else 1.0)
		if pause_progress <= 0:
			is_pausing = false
	elif is_progressing:
		character_progress += chars_per_second * delta * (SPEED_UP_MULT if is_sped_up else 1.0)
		
		if not int(character_progress) == characters_advanced:
			%Text.visible_characters = int(character_progress)
			var idx: int = int(character_progress)
			if idx in pause_indices and pause_indices[idx] > 0:
				is_pausing = true
				pause_progress = 16.0
				pause_indices[idx] -= 1
				return
			
			characters_advanced = int(character_progress)
			if is_odd:
				%CharPlayer.play()
			is_odd = not is_odd
		
		if characters_advanced >= len(message_text):
			finished_progressing.emit()

func show_lines(lines: Array[String], can_skip: bool = true) -> void:
	%Text.visible_characters = 0
	await get_tree().create_timer(1.0).timeout
	i_can_skip = can_skip
	for line in lines:
		line = "[shake][center]" + line + "[/center][/shake]" 
		%Text.text = line 
		pause_indices = {}
		var bb_free_text: String = %Text.get_parsed_text()
		var pause_count: int = 0
		for i in range(len(bb_free_text)):
			if bb_free_text[i] == '_':
				var real_index: int = i - pause_count
				if real_index in pause_indices:
					pause_indices[real_index] += 1
				else:
					pause_indices[real_index] = 1
				pause_count += 1
		message_text = ''.join(bb_free_text.split('_'))
		%Text.text = ''.join(line.split('_'))

		%Text.visible_characters = 0
		characters_advanced = 0
		character_progress = 0

		is_progressing = true
		await finished_progressing
		%Text.visible_ratio = 1.0
		is_progressing = false
	
	await get_tree().create_timer(1.0).timeout

func trans_in() -> void:
	i_can_skip = false
	%Text.visible_characters = 0
	%Skip.visible = false
	get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(self, "modulate:a", 1.0, 0.5)

func trans_out() -> void:
	i_can_skip = false
	get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(self, "modulate:a", 0.0, 0.5)
