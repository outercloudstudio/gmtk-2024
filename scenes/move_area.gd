extends Area2D

@export var tile: Node2D


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


func _physics_process(delta: float) -> void:
	var tile_position = Vector2i(floor(tile.global_position / 16))

	var foward = rotation_to_vector(global_rotation_degrees)

	for item: CharacterBody2D in get_overlapping_bodies():
		var item_tile_position = Vector2i(floor(item.global_position / 16))

		if item_tile_position != tile_position:
			continue

		var velocity = foward

		if foward == Vector2.RIGHT || foward == Vector2.LEFT:
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
