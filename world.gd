extends Node2D
class_name World


@export var conveyor_scene: PackedScene
@export var spawner_scene: PackedScene
@export var accepter_scene: PackedScene
@export var level: Node2D


var is_placing = false
var start_placing_position: Vector2

var tilemap = {}

var preview_tiles = []


func cleanup():
	for child in level.get_children():
		child.queue_free()

	tilemap = {}

	if is_placing:
		reset_placing()


func start():
	var possible_place_locations = []

	for x in range(-5, 5):
		for y in range(-5, 5):
			possible_place_locations.push_back(Vector2i(x, y))

	var place_location = possible_place_locations.pick_random()
	
	for offset in [ Vector2i.ZERO, Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, -1) ]:
		if possible_place_locations.has(place_location + offset):
			possible_place_locations.remove_at(possible_place_locations.find(place_location + offset))

	var spawner: Node2D = spawner_scene.instantiate()
	level.add_child(spawner)

	spawner.global_position = place_location * 16

	var possible_rotations = [ Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN ]

	if place_location.x == -5:
		possible_rotations.remove_at(possible_rotations.find(Vector2i.LEFT))

	if place_location.x == 4:
		possible_rotations.remove_at(possible_rotations.find(Vector2i.RIGHT))

	if place_location.y == -5:
		possible_rotations.remove_at(possible_rotations.find(Vector2i.UP))

	if place_location.x == 4:
		possible_rotations.remove_at(possible_rotations.find(Vector2i.DOWN))

	spawner.setup(place_location, possible_rotations.pick_random(), self)

	spawner.place()
	

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

		if tile_location.x < -5 || tile_location.x >= 5 || tile_location.y < -5 || tile_location.y >= 5:
			continue

		var tile = conveyor_scene.instantiate()
		level.add_child(tile)

		tile.global_position = tile_location * 16

		tile.setup(tile_location, direction, self)

		preview_tiles.push_back(tile)