extends Node

# Sistema de diálogos para interação com NPCs
signal dialogue_started(dialogue_data: Dictionary)
signal dialogue_finished
signal dialogue_choice_selected(choice_index: int)

var current_dialogue: Dictionary = {}
var current_dialogue_index: int = 0
var is_dialogue_active: bool = false
var dialogue_ui: Node = null

# Armazenar diálogos por NPC
var dialogues: Dictionary = {}

func _ready() -> void:
	# Carregar diálogos do arquivo de recursos
	load_dialogues()

func load_dialogues() -> void:
	# Diálogos do tutorial - Nox/Celeste
	dialogues["nox_tutorial_1"] = {
		"speaker": "Nox",
		"lines": [
			"Bem-vindo ao campo de treinamento, jovem.",
			"Hoje vamos testar suas habilidades.",
			"Primeiro, vamos treinar sua movimentação."
		],
		"choices": []
	}
	
	dialogues["celeste_tutorial_movement"] = {
		"speaker": "Celeste",
		"lines": [
			"Use as setas do teclado ou WASD para se mover.",
			"Tente se aproximar do alvo de treinamento."
		],
		"choices": []
	}
	
	dialogues["nox_tutorial_magic"] = {
		"speaker": "Nox",
		"lines": [
			"Agora vamos testar sua magia.",
			"Concentre-se e tente lançar um feitiço no alvo.",
			"Pressione a tecla de magia quando estiver pronto."
		],
		"choices": []
	}
	
	dialogues["celeste_magic_failure"] = {
		"speaker": "Celeste",
		"lines": [
			"O que foi isso?!",
			"Algo estranho aconteceu com sua energia...",
			"Você está bem?"
		],
		"choices": []
	}
	
	dialogues["nox_tutorial_combat"] = {
		"speaker": "Nox",
		"lines": [
			"Parece que a magia ainda não é seu forte.",
			"Vamos focar no combate físico então.",
			"Treine com a espada nos alvos de treinamento."
		],
		"choices": []
	}
	
	# Diálogos da cidade - Esposa do padeiro
	dialogues["baker_wife_initial"] = {
		"speaker": "Esposa do Padeiro",
		"lines": [
			"Por favor, senhor guarda! Meu filho...",
			"Theodor saiu esta manhã para buscar erva-doce na floresta",
			"e ainda não voltou! Estou muito preocupada!"
		],
		"choices": []
	}
	
	dialogues["guard_response"] = {
		"speaker": "Guarda",
		"lines": [
			"Calma, senhora. Crianças costumam se atrasar.",
			"Vou verificar isso assim que possível.",
			"Agora tenho outras patrulhas para fazer."
		],
		"choices": []
	}
	
	dialogues["baker_wife_player"] = {
		"speaker": "Esposa do Padeiro",
		"lines": [
			"Oh, você viu a conversa?",
			"Meu filho Theodor saiu para buscar erva-doce",
			"em uma encosta rochosa na floresta próxima.",
			"Ele já fez isso antes, mas nunca demorou tanto...",
			"O guarda não parece se importar muito.",
			"Você poderia ajudá-lo a procurar?"
		],
		"choices": [
			{"text": "Claro, vou ajudá-lo a encontrar Theodor.", "action": "accept_quest"},
			{"text": "Onde exatamente ele foi?", "action": "ask_location"},
			{"text": "Desculpe, não posso ajudar agora.", "action": "decline_quest"}
		]
	}
	
	dialogues["baker_wife_location"] = {
		"speaker": "Esposa do Padeiro",
		"lines": [
			"A erva-doce cresce em uma encosta rochosa",
			"na entrada da floresta, ao norte da cidade.",
			"Siga a estrada principal e vire à direita",
			"quando ver as árvores maiores começarem.",
			"Theodor conhece o caminho, ele já foi lá várias vezes."
		],
		"choices": [
			{"text": "Entendido, vou procurá-lo lá.", "action": "accept_quest"},
			{"text": "Que tipo de planta é essa erva-doce?", "action": "ask_plant"}
		]
	}
	
	dialogues["baker_wife_plant"] = {
		"speaker": "Esposa do Padeiro",
		"lines": [
			"É uma planta especial que usamos em nossos pães",
			"e doces. Dá um sabor único!",
			"Theodor sempre gostou de ajudar a colhê-la.",
			"Por favor, encontre meu filho..."
		],
		"choices": [
			{"text": "Vou encontrar Theodor, prometo.", "action": "accept_quest"}
		]
	}
	
	dialogues["baker_wife_accept"] = {
		"speaker": "Esposa do Padeiro",
		"lines": [
			"Obrigada! Obrigada mesmo!",
			"Você não imagina o quanto isso significa para mim.",
			"Por favor, traga meu filho em segurança!",
			"Eu e meu marido vamos esperar você aqui na padaria."
		],
		"choices": []
	}
	
	# Diálogos na caverna - Theodor
	dialogues["theodor_scared"] = {
		"speaker": "Theodor",
		"lines": [
			"Q-quem é você?!",
			"Você... você não é uma daquelas criaturas, né?",
			"Eu... eu estava com medo..."
		],
		"choices": [
			{"text": "Estou aqui para ajudar. Sua mãe está preocupada.", "action": "calm_down"},
			{"text": "O que aconteceu aqui?", "action": "ask_what_happened"}
		]
	}
	
	dialogues["theodor_calm"] = {
		"speaker": "Theodor",
		"lines": [
			"Você... você foi enviado pela minha mãe?",
			"Eu thought que ninguém viria me buscar...",
			"As criaturas eram assustadoras...",
			"Eu tentei fugir, mas acabei caindo aqui.",
			"Você pode me tirar daqui?"
		],
		"choices": [
			{"text": "Claro, vamos sair daqui juntos.", "action": "start_escort"},
			{"text": "Primeiro me conta o que aconteceu.", "action": "ask_what_happened"}
		]
	}
	
	dialogues["theodor_story"] = {
		"speaker": "Theodor",
		"lines": [
			"Eu estava colhendo erva-doce como sempre faço...",
			"De repente, vi criaturas que nunca tinha visto antes.",
			"Eram diferentes dos animais da floresta...",
			"Fiquei com muito medo e comecei a correr.",
			"Não vi onde estava indo e caí nesse buraco.",
			"Depois a rocha desmoronou e eu ficquei preso..."
		],
		"choices": [
			{"text": "Vamos embora daqui antes que apareçam mais.", "action": "start_escort"}
		]
	}
	
	dialogues["theodor_grateful"] = {
		"speaker": "Theodor",
		"lines": [
			"Obrigado por me encontrar!",
			"Meus pais devem estar muito preocupados...",
			"Eu nunca mais vou para a floresta sozinho!",
			"Bem... talvez quando eu crescer mais."
		],
		"choices": []
	}
	
	# Diálogos de conclusão
	dialogues["baker_wife_completion"] = {
		"speaker": "Esposa do Padeiro",
		"lines": [
			"Theodor! Meu filho!",
			"Você está bem! Obrigado, obrigado tanto!",
			"Não sabemos como agradecer...",
			"Por favor, aceite isso como recompensa."
		],
		"choices": []
	}
	
	dialogues["baker_completion"] = {
		"speaker": "Padeiro",
		"lines": [
			"Você trouxe nosso filho de volta!",
			"Isso... isso é incrível.",
			"A padaria inteira está em dívida com você.",
			"Sempre que precisar de pão, será por nossa conta!"
		],
		"choices": []
	}

func start_dialogue(dialogue_id: String) -> void:
	if not dialogues.has(dialogue_id):
		print("Diálogo não encontrado: ", dialogue_id)
		return
	
	current_dialogue = dialogues[dialogue_id]
	current_dialogue_index = 0
	is_dialogue_active = true
	
	dialogue_started.emit(current_dialogue)
	
	# Criar UI de diálogo se não existir
	if dialogue_ui == null:
		create_dialogue_ui()
	
	show_current_line()

func show_current_line() -> void:
	if current_dialogue_index >= current_dialogue["lines"].size():
		end_dialogue()
		return
	
	var line_text = current_dialogue["lines"][current_dialogue_index]
	var speaker = current_dialogue["speaker"]
	
	if dialogue_ui:
		dialogue_ui.show_line(speaker, line_text, current_dialogue["choices"])

func advance_dialogue() -> void:
	current_dialogue_index += 1
	
	if current_dialogue_index >= current_dialogue["lines"].size():
		# Mostrar escolhas se houver
		if current_dialogue["choices"].size() > 0:
			if dialogue_ui:
				dialogue_ui.show_choices(current_dialogue["choices"])
		else:
			end_dialogue()
	else:
		show_current_line()

func select_choice(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= current_dialogue["choices"].size():
		return
	
	var choice = current_dialogue["choices"][choice_index]
	dialogue_choice_selected.emit(choice_index)
	
	# Executar ação da escolha
	match choice["action"]:
		"accept_quest":
			get_tree().call_group("quest_system", "start_quest", "baker_son")
		"ask_location":
			start_dialogue("baker_wife_location")
		"ask_plant":
			start_dialogue("baker_wife_plant")
		"decline_quest":
			end_dialogue()
		"calm_down":
			start_dialogue("theodor_calm")
		"ask_what_happened":
			start_dialogue("theodor_story")
		"start_escort":
			get_tree().call_group("quest_system", "complete_objective", "find_theodor")
			start_dialogue("theodor_grateful")

func end_dialogue() -> void:
	is_dialogue_active = false
	dialogue_finished.emit()
	
	if dialogue_ui:
		dialogue_ui.hide_dialogue()

func create_dialogue_ui() -> void:
	# Carregar UI de diálogo da cena
	var dialogue_ui_scene = load("res://scenes/dialogue_ui.tscn")
	if dialogue_ui_scene:
		dialogue_ui = dialogue_ui_scene.instantiate()
		add_child(dialogue_ui)
		
		# Conectar sinais
		dialogue_ui.dialogue_completed.connect(_on_dialogue_ui_completed)
		dialogue_ui.choice_selected.connect(_on_dialogue_ui_choice_selected)

func _on_dialogue_ui_completed() -> void:
	advance_dialogue()

func _on_dialogue_ui_choice_selected(choice_index: int) -> void:
	select_choice(choice_index)

func is_active() -> bool:
	return is_dialogue_active