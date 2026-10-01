extends Node

# Inicializador do jogo - configura tudo no início
func _ready() -> void:
	print("Inicializando Rabbit's Fantasy...")
	
	# Não carregar nível - já está na cena principal
	# initialize_level()
	
	# Configurar jogador
	initialize_player()
	
	# Iniciar tutorial
	start_tutorial()
	
	print("Inicialização concluída!")

func initialize_level() -> void:
	# Removido - nível já está carregado na cena
	pass

func initialize_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("Jogador encontrado e configurado")
		player.add_to_group("player")
		# Configurar posição já está definida na cena

func start_tutorial() -> void:
	var tutorial_system = get_tree().get_first_node_in_group("tutorial_system")
	if tutorial_system:
		tutorial_system.start_tutorial()
		print("Tutorial iniciado")

func _on_level_loaded(level_name: String) -> void:
	print("Nível carregado: ", level_name)
	
	# Configurar eventos específicos do nível
	match level_name:
		"training_ground":
			setup_training_ground_events()
		"aequora_city":
			setup_city_events()
		"forest":
			setup_forest_events()
		"cave":
			setup_cave_events()

func setup_training_ground_events() -> void:
	print("Configurando eventos do treinamento")
	# Conectar eventos específicos do tutorial

func setup_city_events() -> void:
	print("Configurando eventos da cidade")
	# Configurar eventos da missão na cidade

func setup_forest_events() -> void:
	print("Configurando eventos da floresta")
	# Configurar eventos de exploração e combate

func setup_cave_events() -> void:
	print("Configurando eventos da caverna")
	# Configurar eventos do glitch e resgate