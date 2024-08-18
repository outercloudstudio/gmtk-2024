extends Node2D


@export var smoke_scene: PackedScene
@export var explosion_scene: PackedScene


var time_till_explode = 0
var spawned_smoke = false

var smoke: GPUParticles2D

func _ready() -> void:
	time_till_explode = randf_range(20, 40)

	smoke = smoke_scene.instantiate()
	get_parent().add_child.call_deferred(smoke)

	smoke.emitting = false
	

func repair():
	spawned_smoke = false
	time_till_explode = randf_range(20, 40)

	smoke.emitting = false
	
	var dust_scene: PackedScene = load("res://scenes/dust.tscn")
	var dust: GPUParticles2D = dust_scene.instantiate()

	add_child(dust)
	dust.emitting = true


func _process(delta: float) -> void:
	time_till_explode -= delta

	if time_till_explode < 5 && !spawned_smoke:
		spawned_smoke = true

		smoke.emitting = true

		smoke.global_position = global_position

		Static.camera.shake(0.4)

	if time_till_explode <= 0:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		get_parent().get_parent().add_child(explosion)

		explosion.global_position = global_position

		explosion.emitting = true

		get_parent().destroy()

		Static.camera.shake(1.5)
