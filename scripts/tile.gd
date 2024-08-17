extends Node2D


@export var place_on_start = false
@export var place_on_start_direction: Vector2i = Vector2i.RIGHT
@export var can_be_replaced = true
@export var rotation_origin: Node2D


var direction: Vector2i = Vector2i.RIGHT
var _location: Vector2i = Vector2i.ZERO
var _world: World


func setup(location: Vector2i, tile_direction: Vector2i, world: World):
	_location = location
	direction = tile_direction
	_world = world

	rotation_origin.look_at(global_position + Vector2.ONE * 8 + Vector2(tile_direction))

	modulate = Color("#ffffff88")


func place():
	modulate = Color("#ffffffff")

	if _world.tilemap.has(_location):
		_world.tilemap[_location].queue_free()

	_world.tilemap[_location] = self

func _ready() -> void:
	if place_on_start:
		setup(floor(global_position / 16), place_on_start_direction, get_parent().get_parent())
		place()