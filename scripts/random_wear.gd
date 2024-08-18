extends Node2D


@export var smoke_scene: PackedScene
@export var explosion_scene: PackedScene


var time_till_explode = 0
var spawned_smoke = false

var smoke: Node2D

func _ready() -> void:
	time_till_explode = randf_range(20, 40)
	

func repair():
	spawned_smoke = false
	time_till_explode = randf_range(20, 40)

	if smoke != null:
		smoke.queue_free()


func _process(delta: float) -> void:
	time_till_explode -= delta

	if time_till_explode < 5 && !spawned_smoke:
		smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)

		smoke.global_position = global_position

		spawned_smoke = true

		Static.camera.shake(0.4)

	if time_till_explode <= 0:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		get_parent().get_parent().add_child(explosion)

		explosion.global_position = global_position

		explosion.emitting = true

		get_parent().destroy()

		Static.camera.shake(1.5)
