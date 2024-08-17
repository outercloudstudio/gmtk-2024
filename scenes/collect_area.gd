extends Area2D


@export var tile: Node2D


func _physics_process(delta: float) -> void:
	var tile_position = Vector2i(floor(tile.global_position / 16))

	for item: CharacterBody2D in get_overlapping_bodies():
		var item_tile_position = Vector2i(floor(item.global_position / 16))

		if item_tile_position != tile_position:
			continue

		item.queue_free()
		Static.collected_quota += 1
