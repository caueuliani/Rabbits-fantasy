extends Node2D

func _ready() -> void:
	var collision_shapes := find_children("*", "CollisionShape2D", true, false)
	var collision_polygons := find_children("*", "CollisionPolygon2D", true, false)

	print("CollisionShape2D: ", collision_shapes.size())
	print("CollisionPolygon2D: ", collision_polygons.size())
	print("TOTAL DE COLISÕES: ", collision_shapes.size() + collision_polygons.size())
