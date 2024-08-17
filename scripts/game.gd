extends Node2D


@export var world: World
@export var timer_label: Label
@export var quota_label: Label


var round_timer = 30
var quota = 40


func _ready() -> void:
	start()


func _process(delta: float) -> void:
	round_timer -= delta

	timer_label.text = str(floor(round_timer))
	quota_label.text = str(Static.collected_quota) + " / " + str(quota)

	if round_timer <= 0:
		round_timer = 30

		cleanup()
		start()


func cleanup():
	world.cleanup()

	Static.collected_quota = 0


func start():
	world.start()