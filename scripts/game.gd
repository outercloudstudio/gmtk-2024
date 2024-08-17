extends Node2D
class_name Game


@export var world: World
@export var timer_label: Label
@export var quota_holder: Control
@export var quota_item_scene: PackedScene

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
	update_quota_display()

	if round_timer <= 0:
		round_timer = 60

		cleanup()
		start()


func cleanup():
	world.cleanup()

	Static.collected_quota = 0


func start():
	world.start()


func update_quota_display():
	for child in quota_holder.get_children():
		child.queue_free()

	for identifier in Static.quota:
		var quota_item: QuotaItem = quota_item_scene.instantiate()
		quota_holder.add_child(quota_item)

		quota_item.identifier = identifier
		quota_item.amount = Static.quota[identifier] - Static.collected_quota[identifier]

		quota_item.setup()

	pass