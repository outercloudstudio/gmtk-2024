extends CharacterBody2D


@export var identifier: String


var _world: World
var _target: Vector2


func _ready() -> void:
	_world = get_parent().get_parent()

	if has_node("SquashAndStretch"):
		$SquashAndStretch.trigger(Vector2(1.4, 0.6), 8)


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
		var dust_scene: PackedScene = load("res://scenes/dust.tscn")
		var dust: GPUParticles2D = dust_scene.instantiate()

		get_parent().add_child(dust)
		dust.emitting = true
		dust.global_position = global_position

		queue_free()

	move_and_slide()

	velocity = fixed_lerp(velocity, Vector2.ZERO, 6, delta)