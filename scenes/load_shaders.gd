extends Node2D


@export var scenes: Array


func _ready() -> void:
	for scene: PackedScene in scenes:
		var object: Node2D = scene.instantiate()
		add_child(object)

		object.global_position = Vector2(-200, 0)

		if object is GPUParticles2D:
			object.emitting = true

		if object.has_node("Sparks"):
			object.get_node("Sparks").emitting = true