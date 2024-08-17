extends Node2D


@export var world: World
@export var timer_label: Label


var round_timer = 60


func _ready() -> void:
	start()


func _process(delta: float) -> void:
	round_timer -= delta

	timer_label.text = str(floor(round_timer))

	if round_timer <= 0:
		round_timer = 60

		cleanup()
		start()


func cleanup():
	world.cleanup()


func start():
	world.start()