extends Area2D

# Área que detecta entrada do jogador e dispara eventos
@export var trigger_id: String = ""
@export var trigger_once: bool = true
@export var auto_activate: bool = true

var has_triggered: bool = false
var player_in_area: bool = false

signal triggered(trigger_id: String)
signal player_entered(trigger_id: String)
signal player_exited(trigger_id: String)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("area_triggers")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_entered.emit(trigger_id)
		
		if auto_activate and (not trigger_once or not has_triggered):
			activate_trigger()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_exited.emit(trigger_id)

func activate_trigger() -> void:
	if trigger_once and has_triggered:
		return
	
	has_triggered = true
	triggered.emit(trigger_id)
	
	# Notificar sistemas de jogo
	notify_quest_integration()
	notify_level_manager()
	
	print("Trigger ativado: ", trigger_id)

func notify_quest_integration() -> void:
	var quest_integration = get_tree().get_first_node_in_group("quest_integration")
	if quest_integration:
		match trigger_id:
			"forest_entrance":
				quest_integration.on_player_entered_area("forest")
			"herb_slope":
				quest_integration.on_player_entered_area("herb_slope")
			"cave_entrance":
				quest_integration.on_player_entered_area("cave")
			"bakery":
				quest_integration.on_player_entered_area("bakery")

func notify_level_manager() -> void:
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		match trigger_id:
			"to_castle_garden":
				level_manager.transition_to("castle_garden")
			"to_aequora_city":
				level_manager.transition_to("aequora_city")
			"to_forest":
				level_manager.transition_to("forest")
			"to_cave":
				level_manager.transition_to("cave")
			"to_training_ground":
				level_manager.transition_to("training_ground")

func reset_trigger() -> void:
	has_triggered = false
	player_in_area = false

func set_trigger_id(new_id: String) -> void:
	trigger_id = new_id