extends Node2D


@export var smoke_scene: PackedScene
@export var explosion_scene: PackedScene


var time_till_explode = 0
var spawned_smoke = false

var smoke: GPUParticles2D

var _tiggered_tutorial_repair = false

func _ready() -> void:
	time_till_explode = randf_range(20, 60)

	smoke = smoke_scene.instantiate()
	get_parent().add_child.call_deferred(smoke)

	smoke.emitting = false
	smoke.get_node("Sparks").emitting = false

	get_parent().on_destroy.connect(destroy)
	

func repair():
	smoke.emitting = false
	smoke.get_node("Sparks").emitting = false
	
	var dust_scene: PackedScene = load("res://scenes/dust.tscn")
	var dust: GPUParticles2D = dust_scene.instantiate()

	add_child(dust)
	dust.emitting = true

	if !spawned_smoke:
		return

	if Static.is_tutorial && Static.tutorial_stage == "repairing":
		Static.tutorial_repair_count += 1

	spawned_smoke = false

	time_till_explode = randf_range(20, 30)

	Static.audio.stop_fire()

	await get_tree().create_timer(1).timeout

	dust.queue_free()


func destroy():
	if spawned_smoke:
		Static.audio.stop_fire()


func _process(delta: float) -> void:
	if !get_parent().placed:
		return

	if !Static.is_tutorial:
		time_till_explode -= delta

	if Static.is_tutorial && Static.tutorial_stage == "repairing" && !_tiggered_tutorial_repair:
		time_till_explode = 5

		_tiggered_tutorial_repair = true

	if time_till_explode < 8 && !spawned_smoke:
		spawned_smoke = true

		smoke.emitting = true
		smoke.get_node("Sparks").emitting = true

		smoke.global_position = global_position

		Static.camera.shake(0.4)

		Static.audio.play_fire()

	if time_till_explode <= 0:
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		get_parent().get_parent().add_child(explosion)

		explosion.global_position = global_position

		explosion.emitting = true

		get_parent().destroy()

		Static.camera.shake(1.5)

		Static.audio.play("explosion")
