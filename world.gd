extends Node2D
class_name World


@export var conveyor_scene: PackedScene


var is_placing = false
var start_placing_position: Vector2

var tilemap = {}

var preview_tiles = []


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		start_placing()

	if event.is_action_released("place"):
		reset_placing()
		

func start_placing():
	is_placing = true

	start_placing_position = get_global_mouse_position()


func reset_placing():
	is_placing = false

	for tile in preview_tiles:
		tile.place()

	preview_tiles = []


func _process(delta: float) -> void:
	if is_placing:
		update_placing()


func update_placing():
	for tile in preview_tiles:
		tile.queue_free()

	preview_tiles = []

	var target = get_global_mouse_position()

	var offset = target - start_placing_position

	var corrected_offset = Vector2(offset.x, 0)

	if abs(offset.y) > abs(offset.x):
		corrected_offset = Vector2(0, offset.y)

	var start_tile = floor(start_placing_position / 16)
	var end_tile = floor((start_placing_position + corrected_offset) / 16)

	var direction = corrected_offset.normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	for index in range((end_tile - start_tile).length() + 1):
		var tile_location: Vector2i = Vector2i(start_tile + direction * index)

		if tilemap.has(tile_location) && !tilemap[tile_location].can_be_replaced:
			continue

		var tile = conveyor_scene.instantiate()
		add_child(tile)

		tile.global_position = tile_location * 16

		tile.setup(tile_location, direction, self)

		preview_tiles.push_back(tile)