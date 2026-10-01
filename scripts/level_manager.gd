extends Node

# Gerenciador de níveis e transições
signal level_loaded(level_name: String)
signal level_transition_requested(target_level: String, spawn_point: Vector2)

var current_level: Node = null
var player: Node = null
var level_scenes: Dictionary = {}

func _ready() -> void:
	# Criar nó CurrentLevel dinamicamente
	var current_level_node = Node2D.new()
	current_level_node.name = "CurrentLevel"
	add_child(current_level_node)
	current_level = current_level_node
	
	# Registrar cenas dos níveis
	level_scenes["training_ground"] = "res://scenes/training_ground.tscn"
	level_scenes["castle_garden"] = "res://scenes/castle_garden.tscn"
	level_scenes["aequora_city"] = "res://scenes/aequora_city.tscn"
	level_scenes["forest"] = "res://scenes/forest.tscn"
	level_scenes["cave"] = "res://scenes/cave.tscn"
	
	add_to_group("level_manager")
	
	# Encontrar jogador (já está na cena principal)
	find_player()

func find_player() -> void:
	player = get_tree().get_first_node_in_group("player")

func load_level(level_name: String, spawn_point: Vector2 = Vector2.ZERO) -> void:
	if not level_scenes.has(level_name):
		print("Nível não encontrado: ", level_name)
		return
	
	# Remover nível atual se existir
	if current_level:
		current_level.queue_free()
		await current_level.tree_exited
	
	# Carregar novo nível
	var level_scene = load(level_scenes[level_name])
	if not level_scene:
		print("Erro ao carregar cena do nível: ", level_name)
		return
	
	current_level = level_scene.instantiate()
	$CurrentLevel.add_child(current_level)
	
	# Reposicionar jogador
	if player:
		if spawn_point != Vector2.ZERO:
			player.global_position = spawn_point
		else:
			# Ponto de spawn padrão baseado no nível (coordenadas ajustadas para as novas imagens)
			match level_name:
				"training_ground":
					player.global_position = Vector2(561, 701)  # Centro do cenário
				"castle_garden":
					player.global_position = Vector2(561, 701)
				"aequora_city":
					player.global_position = Vector2(561, 701)
				"forest":
					player.global_position = Vector2(561, 701)
				"cave":
					player.global_position = Vector2(561, 701)
	
	level_loaded.emit(level_name)
	print("Nível carregado: ", level_name)

func transition_to(target_level: String, spawn_point: Vector2 = Vector2.ZERO) -> void:
	level_transition_requested.emit(target_level, spawn_point)
	load_level(target_level, spawn_point)

func get_current_level() -> Node:
	return current_level

func get_level_name() -> String:
	if current_level:
		return current_level.name
	return ""