extends CharacterBody2D


var _world: World
var _target: Vector2


func _ready() -> void:
	_world = get_parent().get_parent()


func setup():
	_target = global_position


func get_tile():
	var tile_location = Vector2i(floor(global_position / 16))

	if !_world.tilemap.has(tile_location):
		return null

	return _world.tilemap[tile_location]


func _physics_process(delta: float) -> void:
	if global_position == _target:
		var tile = get_tile()

		_target = global_position + Vector2(tile.direction) * 16

	global_position = global_position.move_toward(_target, 50 * delta)

	if get_tile() == null:
		queue_free()