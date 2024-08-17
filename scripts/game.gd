extends Node2D


@export var world: World
@export var timer_label: Label
@export var quota_label: Label

@export_category("Items")
@export var rod_scene: PackedScene
@export var wire_scene: PackedScene
@export var battery_scene: PackedScene
@export var lightbulb_scene: PackedScene
@export var sheet_scene: PackedScene
@export var button_scene: PackedScene
@export var terminal_scene: PackedScene
@export var keyboard_scene: PackedScene


var round_timer = 60
var quota = 40


func _enter_tree() -> void:
	Static.items = {
		rod = rod_scene,
		wire = wire_scene,
		battery = battery_scene,
		lightbulb = lightbulb_scene,
		sheet = sheet_scene,
		button = button_scene,
		terminal = terminal_scene,
		keyboard = keyboard_scene,
	}
	

func _ready() -> void:
	start()


func _process(delta: float) -> void:
	round_timer -= delta

	timer_label.text = str(floor(round_timer))
	quota_label.text = str(Static.collected_quota) + " / " + str(quota)

	if round_timer <= 0:
		round_timer = 60

		cleanup()
		start()


func cleanup():
	world.cleanup()

	Static.collected_quota = 0


func start():
	world.start()