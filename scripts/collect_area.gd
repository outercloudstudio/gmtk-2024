extends Area2D


@export var tile: Node2D


func _physics_process(delta: float) -> void:
	var tile_position = Vector2i(floor(tile.global_position / 16))

	for item: CharacterBody2D in get_overlapping_bodies():
		var item_tile_position = Vector2i(floor(item.global_position / 16))

		if item_tile_position != tile_position:
			continue

		if !Static.all_collected.has(item.identifier):
			Static.all_collected[item.identifier] = 0

		Static.all_collected[item.identifier] += 1

		if Static.quota.has(item.identifier):
			if Static.collected_quota[item.identifier] < Static.quota[item.identifier]:
				Static.collected_quota[item.identifier] += 1

		item.queue_free()

		if tile.has_node("ActivateSquashAndStretch"):
			tile.get_node("ActivateSquashAndStretch").trigger(Vector2(1.4, 0.6), 8)

		var dust_scene: PackedScene = load("res://scenes/dust.tscn")
		var dust: GPUParticles2D = dust_scene.instantiate()

		add_child(dust)
		dust.emitting = true
		dust.global_position = global_position

		Static.audio.play("spawn")
