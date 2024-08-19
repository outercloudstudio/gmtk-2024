extends Node2D


@export var place_on_start = false
@export var place_on_start_direction: Vector2i = Vector2i.RIGHT
@export var can_be_replaced = true
@export var rotation_origin: Node2D
@export var identifier: String


signal on_setup()
signal on_destroy()

var placed = false
var direction: Vector2i = Vector2i.RIGHT
var is_placing = false
var place_delay = 0
var triggered_place = false
var _location: Vector2i = Vector2i.ZERO
var _world: World

func setup(location: Vector2i, tile_direction: Vector2i, world: World):
	_location = location
	direction = tile_direction
	_world = world

	rotation_origin.look_at(global_position + Vector2.ONE * 8 + Vector2(tile_direction))

	modulate = Color("#ffffff88")

	on_setup.emit()


func place():
	modulate = Color("#ffffffff")

	if _world.tilemap.has(_location):
		_world.tilemap[_location].destroy()

	_world.tilemap[_location] = self

	is_placing = true

	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("place")

		if place_on_start:
			$AnimationPlayer.seek(1, true)
		
		if place_delay > 0:
			$AnimationPlayer.seek(0.01, true)
			$AnimationPlayer.pause()
	else:
		is_placing = false
		placed = true


func finish_place():
	is_placing = false

	Static.camera.shake(0.4)

	if has_node("SquashAndStretch"):
		$SquashAndStretch.trigger(Vector2(1.4, 0.6), 8)

	Static.audio.play("place")

	placed = true


func destroy():
	on_destroy.emit()

	_world.tilemap.erase(_location)

	queue_free()


func _ready() -> void:
	if place_on_start:
		setup(floor(global_position / 16), place_on_start_direction, get_parent().get_parent())
		place()


func _process(delta: float) -> void:
	if !is_placing:
		return

	place_delay -= delta

	if place_delay <= 0:
		triggered_place = true

		$AnimationPlayer.play()


func repair():
	if has_node("RandomWear"):
		$RandomWear.repair()