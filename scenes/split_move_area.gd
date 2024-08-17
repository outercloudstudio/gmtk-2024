extends Area2D


@export var tile: Node2D


var last_item_move_directions = {}
var next_move_left = false


func rotation_to_vector(rotation: float) -> Vector2:
	if rotation == 0:
		return Vector2.RIGHT
	
	if rotation == -180:
		return Vector2.LEFT

	if rotation == -90:
		return Vector2.UP

	if rotation == 90:
		return Vector2.DOWN

	return Vector2.ZERO


func rotate_vector_right(vector: Vector2) -> Vector2:
	return Vector2(-vector.y, vector.x)


func rotate_vector_left(vector: Vector2) -> Vector2:
	return Vector2(vector.y, -vector.x)


func _physics_process(delta: float) -> void:
	var tile_position = Vector2i(floor(tile.global_position / 16))

	var foward = rotation_to_vector(global_rotation_degrees)

	var item_move_directions = {}

	for item: CharacterBody2D in get_overlapping_bodies():
		var item_tile_position = Vector2i(floor(item.global_position / 16))
		
		if item_tile_position != tile_position:
			continue

		if last_item_move_directions.has(item):
			item_move_directions[item] = last_item_move_directions[item]

		if !item_move_directions.has(item):
			item_move_directions[item] = next_move_left
			
			next_move_left = !next_move_left

		var move_direction = foward
		var item_moving_left = item_move_directions[item]

		if item_moving_left:
			move_direction = rotate_vector_left(move_direction)
		else:
			move_direction = rotate_vector_right(move_direction)

		var velocity = move_direction

		if move_direction == Vector2.RIGHT || move_direction == Vector2.LEFT:
			if abs(item.global_position.y - global_position.y) > 1:
				if item.global_position.y < global_position.y:
					velocity += Vector2.DOWN
				else:
					velocity += Vector2.UP
		else:
			if abs(item.global_position.x - global_position.x) > 1:
				if item.global_position.x < global_position.x:
					velocity += Vector2.RIGHT
				else:
					velocity += Vector2.LEFT

		item.velocity = velocity.normalized() * 50

	last_item_move_directions = item_move_directions
