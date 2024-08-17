extends Area2D


@export var tile: Node2D


func _physics_process(delta: float) -> void:
	var tile_position = Vector2i(floor(tile.global_position / 16))

	for item: CharacterBody2D in get_overlapping_bodies():
		var item_tile_position = Vector2i(floor(item.global_position / 16))

		if item_tile_position != tile_position:
			continue

		if Static.collected_quota[item.identifier] < Static.quota[item.identifier]:
			Static.collected_quota[item.identifier] += 1

		item.queue_free()
