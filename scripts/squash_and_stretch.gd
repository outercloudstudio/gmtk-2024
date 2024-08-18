extends Node2D


@export var target: Node2D


var _speed = 12


func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)


func _process(delta: float) -> void:
	target.scale = 	fixed_lerp(target.scale, Vector2.ONE, _speed, delta)


func trigger(scale: Vector2, speed: float):
	_speed = speed

	target.scale = scale