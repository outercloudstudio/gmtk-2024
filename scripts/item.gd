extends CharacterBody2D


@export var identifier: String


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


func fixed_lerp(a, b, decay: float, delta: float):
	return b + (a - b) * exp(-decay * delta)


func _physics_process(delta: float) -> void:
	if get_tile() == null:
		queue_free()

	move_and_slide()

	velocity = fixed_lerp(velocity, Vector2.ZERO, 6, delta)