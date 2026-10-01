extends Node

# Gerenciador principal do jogo
signal game_started
signal game_paused
signal game_resumed
signal player_died
signal level_changed(level_name: String)

var is_paused: bool = false
var current_level: String = ""
var player: Node = null
var dialogue_system: Node = null
var quest_system: Node = null

# Configurações do jogo
var game_difficulty: String = "normal"
var auto_save: bool = true

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
	# Configurar input actions
	setup_input_actions()
	
	# Encontrar sistemas de jogo
	find_game_systems()

func setup_input_actions() -> void:
	# Verificar se as ações já existem
	if not InputMap.has_action("ui_text_input_toggle"):
		InputMap.add_action("ui_text_input_toggle")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_E
		InputMap.action_add_event("ui_text_input_toggle", key_event)
	
	if not InputMap.has_action("attack_basic"):
		InputMap.add_action("attack_basic")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_Z
		InputMap.action_add_event("attack_basic", key_event)
	
	if not InputMap.has_action("attack_heavy"):
		InputMap.add_action("attack_heavy")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_X
		InputMap.action_add_event("attack_heavy", key_event)
	
	if not InputMap.has_action("dodge"):
		InputMap.add_action("dodge")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_SPACE
		InputMap.action_add_event("dodge", key_event)
	
	if not InputMap.has_action("cast_magic"):
		InputMap.add_action("cast_magic")
		var key_event = InputEventKey.new()
		key_event.keycode = KEY_Q
		InputMap.action_add_event("cast_magic", key_event)

func find_game_systems() -> void:
	dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
	quest_system = get_tree().get_first_node_in_group("quest_system")
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	# Pausar jogo
	if Input.is_action_just_pressed("ui_cancel") and not is_paused:
		pause_game()
	elif Input.is_action_just_pressed("ui_cancel") and is_paused:
		resume_game()

func start_game() -> void:
	game_started.emit()
	print("Jogo iniciado!")

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	game_paused.emit()
	print("Jogo pausado")

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	game_resumed.emit()
	print("Jogo retomado")

func game_over() -> void:
	player_died.emit()
	print("Game Over!")

func change_level(level_name: String) -> void:
	current_level = level_name
	level_changed.emit(level_name)
	print("Mudando para nível: ", level_name)

func get_player() -> Node:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	return player

func get_dialogue_system() -> Node:
	if not dialogue_system:
		dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
	return dialogue_system

func get_quest_system() -> Node:
	if not quest_system:
		quest_system = get_tree().get_first_node_in_group("quest_system")
	return quest_system

func save_game() -> void:
	# Implementar sistema de save
	print("Jogo salvo!")

func load_game() -> void:
	# Implementar sistema de load
	print("Jogo carregado!")

func set_difficulty(difficulty: String) -> void:
	game_difficulty = difficulty
	print("Dificuldade definida para: ", difficulty)