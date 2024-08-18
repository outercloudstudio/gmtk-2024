extends Node2D
class_name World


@export var game: Game
@export var conveyor_scene: PackedScene
@export var splitter_scene: PackedScene
@export var constructor_scene: PackedScene
@export var deconstructor_scene: PackedScene


var is_placing = false
var start_placing_position: Vector2
var tilemap = {}
var preview_tiles = []
var _level: Level
var _selected_tile: PackedScene


func _ready() -> void:
	_selected_tile = conveyor_scene


func _process(delta: float) -> void:
	if is_placing:
		update_placing()


func start(level_scene: PackedScene):
	_level = level_scene.instantiate()

	add_child(_level)

	return _level


func cleanup():
	_level.queue_free()

	tilemap = {}

	if is_placing:
		reset_placing()
	

func _input(event: InputEvent) -> void:
	if Static.state != "play":
		return

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


func update_placing():
	for tile in preview_tiles:
		tile.queue_free()

	preview_tiles = []

	var target = get_global_mouse_position()

	if _selected_tile == null:
		var tile_location: Vector2i = Vector2i(floor(target / 16))

		if tilemap.has(tile_location) && tilemap[tile_location].can_be_replaced:
			tilemap[tile_location].queue_free()
			tilemap.erase(tile_location)

		return

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

		if tile_location.x < -4 || tile_location.x >= 4 || tile_location.y < -4 || tile_location.y >= 4:
			continue

		var tile = _selected_tile.instantiate()
		_level.add_child(tile)

		tile.global_position = tile_location * 16

		tile.setup(tile_location, direction, self)

		tile.place_delay = index * 0.05

		preview_tiles.push_back(tile)


func select_conveyor():
	_selected_tile = conveyor_scene


func select_splitter():
	_selected_tile = splitter_scene


func select_constructor():
	_selected_tile = constructor_scene


func select_deconstructor():
	_selected_tile = deconstructor_scene


func select_delete():
	_selected_tile = null


func start_game():
	game.start()


func restart():
	game.restart()


func next():
	game.next()