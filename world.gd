extends Node2D


@export var conveyor_scene: PackedScene


var is_placing = false

var tilemap = {}

var last_placed_position: Vector2i = Vector2i.RIGHT
var last_placed_direction: Vector2i = Vector2i.RIGHT
var placed_tiles = 0
var last_placed_tile = null

var placed_positions = []


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		is_placing = true

	if event.is_action_released("place"):
		is_placing = false

		last_placed_position = Vector2i.RIGHT
		placed_tiles = 0

		placed_positions = []


func _process(delta: float) -> void:
	if is_placing:
		var target_position: Vector2 = floor(get_global_mouse_position() / 16)

		var distance = target_position - Vector2(last_placed_position)

		if distance.length() <= 1 || placed_tiles == 0:
			place_tile(target_position, conveyor_scene)

		else:
			var current_position: Vector2 = Vector2(last_placed_position)

			var offset = target_position - current_position
			
			var direction = Vector2(offset.x, 0).normalized()
			
			if direction.length() == 0:
				direction = Vector2(0, offset.y).normalized()

			print("direction 1 ", direction)

			while (target_position - current_position).x != 0 && (target_position - current_position).y != 0:
				place_tile(current_position, conveyor_scene)

				current_position += direction

			offset = target_position - current_position
			
			direction = Vector2(offset.x, 0).normalized()

			if direction.length() == 0:
				direction = Vector2(0, offset.y).normalized()

			print("direction 2 ", direction)

			while (target_position - current_position).x != 0 || (target_position - current_position).y != 0:
				place_tile(current_position, conveyor_scene)

				current_position += direction

		


func place_tile(tile_position: Vector2i, tile_scene: PackedScene):
	if placed_positions.has(tile_position):
		return

	placed_positions.push_back(tile_position)

	var place_position = tile_position * 16
	var tile: Node2D = tile_scene.instantiate()

	if tilemap.has(tile_position):
		var other_tile: Node2D = tilemap[tile_position]
		other_tile.queue_free()

	tilemap[tile_position] = tile

	add_child(tile)

	tile.global_position = place_position

	if placed_tiles == 0:
		tile.place(Vector2i.RIGHT, Vector2i.RIGHT)

		last_placed_direction = Vector2i.RIGHT

		print("place first")

	elif placed_tiles == 1:
		var direction = tile_position - last_placed_position

		last_placed_tile.place(direction, direction)

		tile.place(direction, direction)

		last_placed_direction = direction

		print("place second ", direction)

	else:
		var direction = tile_position - last_placed_position

		last_placed_tile.place(last_placed_direction, direction)

		tile.place(direction, direction)

		last_placed_direction = direction

		print("place next ", direction)


	last_placed_tile = tile

	last_placed_position = tile_position

	placed_tiles += 1
