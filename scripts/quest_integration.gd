extends Node

# Integração entre sistemas de jogo para missões
signal quest_phase_changed(quest_id: String, phase: String)

var quest_phases: Dictionary = {}
var current_quest_phase: Dictionary = {}

func _ready() -> void:
	setup_quest_phases()
	add_to_group("quest_integration")

func setup_quest_phases() -> void:
	# Fases da missão "O Filho do Padeiro"
	quest_phases["baker_son"] = {
		"start": {
			"triggers": ["talk_to_baker_wife"],
			"next_phase": "city_exploration"
		},
		"city_exploration": {
			"triggers": ["enter_forest"],
			"next_phase": "forest_exploration"
		},
		"forest_exploration": {
			"triggers": ["find_herb_slope"],
			"next_phase": "investigation"
		},
		"investigation": {
			"triggers": ["investigate_clues"],
			"next_phase": "cave_entrance"
		},
		"cave_entrance": {
			"triggers": ["enter_cave"],
			"next_phase": "cave_exploration"
		},
		"cave_exploration": {
			"triggers": ["use_glitch", "find_theodor"],
			"next_phase": "rescue"
		},
		"rescue": {
			"triggers": ["escort_theodor"],
			"next_phase": "return"
		},
		"return": {
			"triggers": ["return_to_bakery"],
			"next_phase": "completed"
		},
		"completed": {
			"triggers": [],
			"next_phase": ""
		}
	}

func start_quest_phase(quest_id: String, phase: String) -> void:
	if not quest_phases.has(quest_id):
		return
	
	current_quest_phase[quest_id] = phase
	quest_phase_changed.emit(quest_id, phase)
	
	print("Missão ", quest_id, " entrou na fase: ", phase)
	
	# Atualizar objetivos do sistema de missões
	update_quest_objectives(quest_id, phase)

func trigger_quest_event(quest_id: String, event: String) -> void:
	if not current_quest_phase.has(quest_id):
		return
	
	var current_phase = current_quest_phase[quest_id]
	var phase_data = quest_phases[quest_id][current_phase]
	
	if event in phase_data["triggers"]:
		var next_phase = phase_data["next_phase"]
		if next_phase != "":
			start_quest_phase(quest_id, next_phase)

func update_quest_objectives(quest_id: String, phase: String) -> void:
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	if not quest_system:
		return
	
	# Mapear fases para objetivos
	var objective_mapping = {
		"start": "talk_to_baker_wife",
		"city_exploration": "enter_forest",
		"forest_exploration": "find_herb_slope",
		"investigation": "investigate_clues",
		"cave_entrance": "enter_cave",
		"cave_exploration": "find_theodor",
		"rescue": "escort_theodor",
		"return": "return_to_bakery"
	}
	
	if objective_mapping.has(phase):
		var objective_id = objective_mapping[phase]
		quest_system.complete_objective(quest_id, objective_id)

func on_player_entered_area(area_name: String) -> void:
	# Verificar eventos baseados em áreas
	match area_name:
		"forest":
			trigger_quest_event("baker_son", "enter_forest")
		"herb_slope":
			trigger_quest_event("baker_son", "find_herb_slope")
		"cave":
			trigger_quest_event("baker_son", "enter_cave")
		"bakery":
			trigger_quest_event("baker_son", "return_to_bakery")

func on_npc_interacted(npc_name: String) -> void:
	# Verificar eventos baseados em NPCs
	match npc_name:
		"Esposa do Padeiro":
			trigger_quest_event("baker_son", "talk_to_baker_wife")
		"Theodor":
			trigger_quest_event("baker_son", "find_theodor")

func on_item_collected(item_id: String) -> void:
	# Verificar eventos baseados em itens
	match item_id:
		"clue_herb":
			trigger_quest_event("baker_son", "investigate_clues")

func on_glitch_used() -> void:
	# Evento especial de glitch
	trigger_quest_event("baker_son", "use_glitch")

func on_enemy_defeated(enemy_name: String) -> void:
	# Verificar eventos baseados em inimigos
	print("Inimigo derrotado: ", enemy_name)

func get_current_phase(quest_id: String) -> String:
	if current_quest_phase.has(quest_id):
		return current_quest_phase[quest_id]
	return ""