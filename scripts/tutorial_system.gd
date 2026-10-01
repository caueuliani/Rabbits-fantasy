extends Node

# Sistema de tutorial gerenciado
signal tutorial_step_changed(step_name: String)
signal tutorial_completed
signal tutorial_objective_completed(objective: String)

var current_step: String = ""
var tutorial_steps: Dictionary = {}
var active_objectives: Array = []
var tutorial_active: bool = false

# Configuração dos passos do tutorial
func _ready() -> void:
	setup_tutorial_steps()
	add_to_group("tutorial_system")

func setup_tutorial_steps() -> void:
	tutorial_steps = {
		"start": {
			"objectives": ["wait_for_intro"],
			"dialogue": "nox_tutorial_1",
			"next_step": "movement"
		},
		"movement": {
			"objectives": ["learn_movement", "reach_target"],
			"dialogue": "celeste_tutorial_movement",
			"next_step": "magic"
		},
		"magic": {
			"objectives": ["try_magic", "witness_glitch"],
			"dialogue": "nox_tutorial_magic",
			"next_step": "magic_failure"
		},
		"magic_failure": {
			"objectives": ["observe_failure"],
			"dialogue": "celeste_magic_failure",
			"next_step": "combat"
		},
		"combat": {
			"objectives": ["learn_basic_attack", "learn_heavy_attack", "learn_dodge", "defeat_targets"],
			"dialogue": "nox_tutorial_combat",
			"next_step": "interruption"
		},
		"interruption": {
			"objectives": ["listen_to_interruption"],
			"dialogue": "",
			"next_step": "completed"
		},
		"completed": {
			"objectives": [],
			"dialogue": "",
			"next_step": ""
		}
	}

func start_tutorial() -> void:
	tutorial_active = true
	current_step = "start"
	active_objectives = tutorial_steps[current_step]["objectives"].duplicate()
	
	tutorial_step_changed.emit(current_step)
	print("Tutorial iniciado: ", current_step)
	
	# Iniciar diálogo inicial se houver
	var dialogue_id = tutorial_steps[current_step]["dialogue"]
	if dialogue_id != "":
		start_dialogue(dialogue_id)

func advance_to_next_step() -> void:
	if not tutorial_steps.has(current_step):
		return
	
	var next_step = tutorial_steps[current_step]["next_step"]
	if next_step == "":
		complete_tutorial()
		return
	
	current_step = next_step
	active_objectives = tutorial_steps[current_step]["objectives"].duplicate()
	
	tutorial_step_changed.emit(current_step)
	print("Tutorial avançou para: ", current_step)
	
	# Iniciar diálogo do próximo passo
	var dialogue_id = tutorial_steps[current_step]["dialogue"]
	if dialogue_id != "":
		start_dialogue(dialogue_id)

func complete_objective(objective: String) -> void:
	if objective in active_objectives:
		active_objectives.erase(objective)
		tutorial_objective_completed.emit(objective)
		print("Objetivo do tutorial completado: ", objective)
		
		# Verificar se todos os objetivos do passo atual foram completados
		if active_objectives.is_empty():
			advance_to_next_step()

func complete_tutorial() -> void:
	tutorial_active = false
	tutorial_completed.emit()
	
	# Marcar tutorial como completado no sistema de missões
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	if quest_system:
		quest_system.complete_objective("tutorial_completed", "tutorial")
	
	print("Tutorial completado!")

func start_dialogue(dialogue_id: String) -> void:
	var dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
	if dialogue_system:
		dialogue_system.start_dialogue(dialogue_id)

func check_movement_achievement() -> void:
	if current_step == "movement":
		complete_objective("learn_movement")

func check_target_reached() -> void:
	if current_step == "movement":
		complete_objective("reach_target")

func check_magic_attempt() -> void:
	if current_step == "magic":
		complete_objective("try_magic")

func check_glitch_witnessed() -> void:
	if current_step == "magic_failure":
		complete_objective("witness_glitch")

func check_basic_attack_learned() -> void:
	if current_step == "combat":
		complete_objective("learn_basic_attack")

func check_heavy_attack_learned() -> void:
	if current_step == "combat":
		complete_objective("learn_heavy_attack")

func check_dodge_learned() -> void:
	if current_step == "combat":
		complete_objective("learn_dodge")

func check_targets_defeated() -> void:
	if current_step == "combat":
		complete_objective("defeat_targets")

func check_interruption() -> void:
	if current_step == "interruption":
		complete_objective("listen_to_interruption")

func get_current_step() -> String:
	return current_step

func get_active_objectives() -> Array:
	return active_objectives

func is_tutorial_active() -> bool:
	return tutorial_active

func get_step_info(step_name: String) -> Dictionary:
	if tutorial_steps.has(step_name):
		return tutorial_steps[step_name]
	return {}

func skip_tutorial() -> void:
	print("Tutorial pulado")
	tutorial_active = false
	current_step = "completed"
	tutorial_completed.emit()