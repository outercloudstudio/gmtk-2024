extends Node2D


@export var item_scene: PackedScene


var _timer = 0.5


func _process(delta: float) -> void:
	_timer -= delta

	if _timer <= 0:
		_timer = 0.5

		var item = item_scene.instantiate()

		get_parent().get_parent().add_child(item)

		item.global_position = global_position

		item.setup()
