extends Node2D


@export var tile: Node2D


func _ready() -> void:
	tile.on_setup.connect(_update)


func _process(delta: float) -> void:
	_update()


func _update():
	$"Up".visible = tile.direction == Vector2i.UP
	$"Right".visible = tile.direction == Vector2i.RIGHT
	$"Left".visible = tile.direction == Vector2i.LEFT
	$"Down".visible = tile.direction == Vector2i.DOWN