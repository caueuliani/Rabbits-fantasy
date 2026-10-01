extends Node

# Sistema de gerenciamento de missões
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal objective_completed(quest_id: String, objective_id: String)
signal objective_added(quest_id: String, objective_data: Dictionary)

var active_quests: Dictionary = {}
var completed_quests: Array = []
var failed_quests: Array = []

# Definição das missões
var quest_definitions: Dictionary = {}

func _ready() -> void:
	load_quest_definitions()
	add_to_group("quest_system")

func load_quest_definitions() -> void:
	# Missão 001: O Filho do Padeiro
	quest_definitions["baker_son"] = {
		"title": "O Filho do Padeiro",
		"description": "Encontrar Theodor, filho do padeiro, que saiu para buscar erva-doce na floresta e ainda não retornou.",
		"objectives": [
			{
				"id": "talk_to_baker_wife",
				"description": "Conversar com a esposa do padeiro sobre o desaparecimento de Theodor",
				"completed": false
			},
			{
				"id": "enter_forest",
				"description": "Entrar na floresta próxima a Aequora",
				"completed": false
			},
			{
				"id": "find_herb_slope",
				"description": "Encontrar a encosta onde a erva-doce cresce",
				"completed": false
			},
			{
				"id": "investigate_clues",
				"description": "Investigar pistas deixadas por Theodor",
				"completed": false
			},
			{
				"id": "find_cave_entrance",
				"description": "Encontrar a abertura que leva à caverna",
				"completed": false
			},
			{
				"id": "enter_cave",
				"description": "Entrar na caverna",
				"completed": false
			},
			{
				"id": "find_theodor",
				"description": "Encontrar Theodor na caverna",
				"completed": false
			},
			{
				"id": "escort_theodor",
				"description": "Escoltar Theodor de volta à cidade",
				"completed": false
			},
			{
				"id": "return_to_bakery",
				"description": "Retornar à padaria com Theodor",
				"completed": false
			}
		],
		"rewards": {
			"experience": 100,
			"gold": 50,
			"items": []
		},
		"prerequisites": ["tutorial_completed"],
		"status": "not_started"
	}

func start_quest(quest_id: String) -> bool:
	if not quest_definitions.has(quest_id):
		print("Missão não encontrada: ", quest_id)
		return false
	
	if active_quests.has(quest_id) or quest_id in completed_quests:
		print("Missão já ativa ou completada: ", quest_id)
		return false
	
	var quest_data = quest_definitions[quest_id].duplicate()
	
	# Verificar pré-requisitos
	if quest_data.has("prerequisites"):
		for prereq in quest_data["prerequisites"]:
			if prereq not in completed_quests:
				print("Pré-requisito não atendido: ", prereq)
				return false
	
	quest_data["status"] = "active"
	quest_data["start_time"] = Time.get_unix_time_from_system()
	
	active_quests[quest_id] = quest_data
	quest_started.emit(quest_id)
	
	print("Missão iniciada: ", quest_data["title"])
	return true

func complete_objective(quest_id: String, objective_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	var quest = active_quests[quest_id]
	
	for objective in quest["objectives"]:
		if objective["id"] == objective_id and not objective["completed"]:
			objective["completed"] = true
			objective_completed.emit(quest_id, objective_id)
			print("Objetivo completado: ", objective["description"])
			
			# Verificar se todos os objetivos foram completados
			check_quest_completion(quest_id)
			break

func check_quest_completion(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	var quest = active_quests[quest_id]
	var all_completed = true
	
	for objective in quest["objectives"]:
		if not objective["completed"]:
			all_completed = false
			break
	
	if all_completed:
		complete_quest(quest_id)

func complete_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	var quest = active_quests[quest_id]
	quest["status"] = "completed"
	quest["completion_time"] = Time.get_unix_time_from_system()
	
	completed_quests.append(quest_id)
	active_quests.erase(quest_id)
	
	# Dar recompensas
	give_quest_rewards(quest)
	
	quest_completed.emit(quest_id)
	print("Missão completada: ", quest["title"])

func fail_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	var quest = active_quests[quest_id]
	quest["status"] = "failed"
	
	failed_quests.append(quest_id)
	active_quests.erase(quest_id)
	
	quest_failed.emit(quest_id)
	print("Missão falhou: ", quest["title"])

func give_quest_rewards(quest: Dictionary) -> void:
	if not quest.has("rewards"):
		return
	
	var rewards = quest["rewards"]
	
	# Dar experiência
	if rewards.has("experience"):
		print("Ganhou ", rewards["experience"], " de experiência")
		get_tree().call_group("player", "add_experience", rewards["experience"])
	
	# Dar ouro
	if rewards.has("gold"):
		print("Ganhou ", rewards["gold"], " de ouro")
		get_tree().call_group("player", "add_gold", rewards["gold"])
	
	# Dar itens
	if rewards.has("items"):
		for item in rewards["items"]:
			print("Ganhou item: ", item)
			get_tree().call_group("player", "add_item", item)

func get_quest_status(quest_id: String) -> String:
	if active_quests.has(quest_id):
		return "active"
	elif quest_id in completed_quests:
		return "completed"
	elif quest_id in failed_quests:
		return "failed"
	else:
		return "not_started"

func get_active_quests() -> Dictionary:
	return active_quests

func get_quest_objectives(quest_id: String) -> Array:
	if active_quests.has(quest_id):
		return active_quests[quest_id]["objectives"]
	return []

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests

func add_objective(quest_id: String, objective_data: Dictionary) -> void:
	if not active_quests.has(quest_id):
		return
	
	active_quests[quest_id]["objectives"].append(objective_data)
	objective_added.emit(quest_id, objective_data)

func update_objective_description(quest_id: String, objective_id: String, new_description: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	for objective in active_quests[quest_id]["objectives"]:
		if objective["id"] == objective_id:
			objective["description"] = new_description
			break