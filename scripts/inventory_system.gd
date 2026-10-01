extends Node

# Sistema de inventário básico
signal item_added(item: Dictionary)
signal item_removed(item_id: String)
signal gold_changed(new_amount: int)
signal experience_changed(new_amount: int)

var inventory: Array = []
var max_slots: int = 20
var gold: int = 0
var experience: int = 0
var level: int = 1

# Definição de itens
var item_database: Dictionary = {
	"health_potion": {
		"id": "health_potion",
		"name": "Poção de Vida",
		"description": "Restaura 50 HP",
		"type": "consumable",
		"effect": "heal",
		"value": 50,
		"stackable": true,
		"max_stack": 10,
		"icon": "res://assets/items/health_potion.png"
	},
	"mana_potion": {
		"id": "mana_potion",
		"name": "Poção de Mana",
		"description": "Restaura 30 Mana",
		"type": "consumable",
		"effect": "mana",
		"value": 30,
		"stackable": true,
		"max_stack": 10,
		"icon": "res://assets/items/mana_potion.png"
	},
	"iron_sword": {
		"id": "iron_sword",
		"name": "Espada de Ferro",
		"description": "Espada básica de ferro",
		"type": "weapon",
		"damage": 15,
		"stackable": false,
		"icon": "res://assets/items/iron_sword.png"
	},
	"herb": {
		"id": "herb",
		"name": "Erva Medicinal",
		"description": "Erva com propriedades curativas",
		"type": "material",
		"stackable": true,
		"max_stack": 20,
		"icon": "res://assets/items/herb.png"
	}
}

func _ready() -> void:
	add_to_group("inventory_system")

func add_item(item_id: String, quantity: int = 1) -> bool:
	if not item_database.has(item_id):
		print("Item não encontrado no banco de dados: ", item_id)
		return false
	
	var item_data = item_database[item_id].duplicate()
	
	# Verificar se é stackable e já existe no inventário
	if item_data["stackable"]:
		var existing_item = find_item(item_id)
		if existing_item:
			if existing_item["quantity"] < item_data["max_stack"]:
				var space_left = item_data["max_stack"] - existing_item["quantity"]
				var to_add = min(quantity, space_left)
				existing_item["quantity"] += to_add
				quantity -= to_add
				
				if quantity <= 0:
					item_added.emit(existing_item)
					return true
	
	# Se ainda houver quantidade para adicionar, criar novo slot
	while quantity > 0 and inventory.size() < max_slots:
		var new_item = item_data.duplicate()
		var to_add = min(quantity, item_data["max_stack"] if item_data["stackable"] else 1)
		new_item["quantity"] = to_add
		inventory.append(new_item)
		quantity -= to_add
		item_added.emit(new_item)
	
	if quantity > 0:
		print("Inventário cheio! Não foi possível adicionar todos os itens.")
		return false
	
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	var item = find_item(item_id)
	if not item:
		return false
	
	if item["quantity"] >= quantity:
		item["quantity"] -= quantity
		if item["quantity"] <= 0:
			inventory.erase(item)
			item_removed.emit(item_id)
		return true
	
	return false

func find_item(item_id: String) -> Dictionary:
	for item in inventory:
		if item["id"] == item_id:
			return item
	return {}

func use_item(item_id: String) -> bool:
	var item = find_item(item_id)
	if not item:
		return false
	
	if item["type"] == "consumable":
		apply_item_effect(item)
		remove_item(item_id, 1)
		return true
	
	return false

func apply_item_effect(item: Dictionary) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	match item["effect"]:
		"heal":
			if player.has_method("heal"):
				player.heal(item["value"])
		"mana":
			if player.has_method("restore_mana"):
				player.restore_mana(item["value"])

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)
	print("Ganho de ouro: ", amount, " | Total: ", gold)

func remove_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false

func add_experience(amount: int) -> void:
	experience += amount
	experience_changed.emit(experience)
	
	# Verificar level up
	check_level_up()

func check_level_up() -> void:
	var exp_needed = get_experience_needed_for_level(level + 1)
	if experience >= exp_needed:
		level_up()

func get_experience_needed_for_level(target_level: int) -> int:
	# Fórmula simples: level * 100
	return target_level * 100

func level_up() -> void:
	level += 1
	print("Level Up! Nível atual: ", level)
	
	# Dar benefícios de level up
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.max_health += 10
		player.current_health = player.max_health
		player.max_mana += 5
		player.current_mana = player.max_mana

func get_inventory() -> Array:
	return inventory

func get_gold() -> int:
	return gold

func get_experience() -> int:
	return experience

func get_level() -> int:
	return level

func get_item_count(item_id: String) -> int:
	var item = find_item(item_id)
	if item:
		return item["quantity"]
	return 0

func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity