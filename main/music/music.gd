class_name Music
extends Node

var lead: AudioStreamPlayer

func _ready() -> void:
	%Normal.volume_db = -16
	%Battle.volume_db = -64
	%Human.volume_db = -64
	lead = %Normal

func _process(delta: float) -> void:
	if is_instance_valid(lead):
		lead.volume_db = lerp(lead.volume_db, -16.0, delta * 2)
	for child in get_children():
		if child == lead:
			continue
		child.volume_db = lerp(child.volume_db, -64.0, delta * 0.3)

func set_lead(lead_name: String) -> void:
	if lead_name == "":
		lead = null
	else:
		lead = get_node(lead_name.capitalize())
