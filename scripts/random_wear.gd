extends Node2D


@export var smoke_scene: PackedScene
@export var explosion_scene: PackedScene


var time_tille_explode = 0
var spawned_smoke = false


func _ready() -> void:
	time_tille_explode = randf_range(20, 40)
	

func _process(delta: float) -> void:
	time_tille_explode -= delta

	if time_tille_explode < 5 && !spawned_smoke:
		var smoke: Node2D = smoke_scene.instantiate()
		get_parent().add_child(smoke)

		smoke.global_position = global_position

		spawned_smoke = true

	if time_tille_explode <= 0:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		get_parent().get_parent().add_child(explosion)

		explosion.global_position = global_position

		explosion.emitting = true

		get_parent().destroy()
