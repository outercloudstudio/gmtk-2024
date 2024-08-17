extends Node2D


@export var rotation_origin: Node2D


var _direction: Vector2i = Vector2i.RIGHT
var _location: Vector2i = Vector2i.ZERO
var _world: World


func setup(location: Vector2i, direction: Vector2i, world: World):
	_location = location
	_direction = direction
	_world = world

	rotation_origin.look_at(global_position + Vector2.ONE * 8 + Vector2(direction))

	modulate = Color("#ffffff88")


func place():
	modulate = Color("#ffffffff")

	if _world.tilemap.has(_location):
		_world.tilemap[_location].queue_free()

	_world.tilemap[_location] = self