extends Node2D
class_name World


@export var game: Game
@export var conveyor_scene: PackedScene
@export var splitter_scene: PackedScene
@export var constructor_scene: PackedScene
@export var deconstructor_scene: PackedScene
@export var tile_indicator: Sprite2D


var is_placing = false
var start_placing_position: Vector2
var tilemap = {}
var preview_tiles = []
var _level: Level
var _selected_tile: PackedScene
var _selected_repair_tool = false


var repair_cooldown = 0


func _ready() -> void:
	_selected_tile = conveyor_scene


func _process(delta: float) -> void:
	if is_placing:
		update_placing()

	repair_cooldown -= delta

	var mouse_tile_position = floor(get_global_mouse_position() / 16)

	tile_indicator.visible = mouse_tile_position.x >= -4 && mouse_tile_position.y >= -4 && mouse_tile_position.x < 4 && mouse_tile_position.y < 4 

	tile_indicator.global_position = fixed_lerp(tile_indicator.global_position, mouse_tile_position * 16 + Vector2.ONE * 8, 24, delta)


func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)


func start(level_scene: PackedScene):
	_level = level_scene.instantiate()

	add_child(_level)

	open_tools()

	return _level


func open_tools():
	for tool in $Tools.get_children():
		await get_tree().create_timer(0.02).timeout

		tool.is_enabled = true


func cleanup():
	for location in tilemap:
		tilemap[location].destroy()

	_level.queue_free()

	tilemap = {}

	if is_placing:
		reset_placing()

	for tool in $Tools.get_children():
		await get_tree().create_timer(0.02).timeout

		tool.is_enabled = false
	

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

		if _selected_repair_tool:
			if tilemap.has(tile_location) && tilemap[tile_location].can_be_replaced:
				if repair_cooldown <= 0:
					tilemap[tile_location].repair()
					repair_cooldown = 0.15

					Static.audio.play("repair")

				Static.camera.shake(0.3)

		else:
			if tilemap.has(tile_location) && tilemap[tile_location].can_be_replaced:
				tilemap[tile_location].destroy()

				Static.camera.shake(0.4)

				Static.audio.play("destroy")

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
	_selected_repair_tool = false

	Static.audio.play("click")


func select_splitter():
	_selected_tile = splitter_scene
	_selected_repair_tool = false

	Static.audio.play("click")


func select_constructor():
	_selected_tile = constructor_scene
	_selected_repair_tool = false

	Static.audio.play("click")


func select_deconstructor():
	_selected_tile = deconstructor_scene
	_selected_repair_tool = false

	Static.audio.play("click")


func select_delete():
	_selected_tile = null
	_selected_repair_tool = false

	Static.audio.play("click")


func select_repair():
	_selected_tile = null
	_selected_repair_tool = true

	Static.audio.play("click")


func start_game():
	game.start()

	Static.audio.play("click")


func restart():
	game.restart()

	Static.audio.play("click")


func next():
	game.next()

	Static.audio.play("click")