extends Node2D
class_name Game


@export var world: World
@export var timer_label: Label
@export var performance_label: Label
@export var quota_holder: Control
@export var quota_item_scene: PackedScene
@export var level_scenes: Array
@export var main_menu_animation_player: AnimationPlayer
@export var results_menu_animation_player: AnimationPlayer
@export var lower_bound_label: Label
@export var upper_bound_label: Label
@export var graph: Control

@export_category("Items")
@export var rod_scene: PackedScene
@export var wire_scene: PackedScene
@export var battery_scene: PackedScene
@export var lightbulb_scene: PackedScene
@export var sheet_scene: PackedScene
@export var button_scene: PackedScene
@export var terminal_scene: PackedScene
@export var keyboard_scene: PackedScene
@export var scrap_scene: PackedScene
@export var copper_bit_scene: PackedScene
@export var plastic_blob_bit_scene: PackedScene

var _round_timer = 60
var _level_scene = null

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
		scrap = scrap_scene,
		copper_bit = copper_bit_scene,
		plastic_blob = plastic_blob_bit_scene
	}


func _process(delta: float) -> void:
	if Static.state == "play":
		_round_timer -= delta

		timer_label.text = str(ceil(_round_timer))
		_update_quota_display()

		if _round_timer <= 15:
			Static.audio.music_state = "play_intense"

		if _round_timer <= 0:
			end_round()


func start_round():
	Static.state = "play"

	# _round_timer = 60
	_round_timer = 10

	var level = world.start(_level_scene)

	Static.quota = level.quota
	Static.score = 0

	Static.collected_quota = {}
	for identifier in Static.quota:
		Static.collected_quota[identifier] = 0

	Static.audio.music_state = "play"



func end_round():
	Static.state = "results"

	performance_label.text = str(Static.score)

	results_menu_animation_player.play("show")

	var failed = false

	for item in Static.quota:
		if Static.quota[item] - Static.collected_quota[item] > 0:
			failed = true
			break

	if failed:
		performance_label.modulate = Color("#ff0000")
	else:
		performance_label.modulate = Color("#00ff00")
	
	world.cleanup()

	Static.audio.music_state = "finish"

	draw_graph([ 250, 500, 500, 500, 1000, 1002, 2000, Static.score ], Static.score)


func start():
	_level_scene = level_scenes.pick_random()
	main_menu_animation_player.play("hide")

	start_round()


func restart():
	results_menu_animation_player.play("hide")

	start_round()


func next():
	_level_scene = level_scenes.pick_random()
	results_menu_animation_player.play("hide")

	start_round()


func _update_quota_display():
	for child in quota_holder.get_children():
		child.queue_free()

	for identifier in Static.quota:
		var quota_item: QuotaItem = quota_item_scene.instantiate()
		quota_holder.add_child(quota_item)

		quota_item.identifier = identifier
		quota_item.amount = Static.quota[identifier] - Static.collected_quota[identifier]

		quota_item.setup()

	pass


func draw_graph(data: Array, your_score):
	var lowest = 0
	var highest = 1000

	var graph_width = floor(graph.size.x / 4)

	for score in data:
		lowest = min(lowest, score)
		highest = max(highest, score)

	var bucket_size = (highest - lowest) / (graph_width)

	var buckets = []

	for x in range(graph_width + 1):
		buckets.push_back(0)

	for score in data:
		var bucket = floor((score - lowest) / bucket_size)

		buckets[bucket] += 1

	var max_count = 0

	for mode in buckets:
		max_count = max(max_count, mode)

	for child in graph.get_children():
		child.queue_free()

	var your_bucket_index = floor((your_score - lowest) / bucket_size)

	print(buckets)

	for bucket_index in range(len(buckets)):
		var bar = ColorRect.new()

		var height = floor(graph.size.y * buckets[bucket_index] / max_count)

		graph.add_child(bar)
		bar.position = Vector2(bucket_index * 4, graph.size.y - height)
		bar.size = Vector2(4, height)

		bar.color = Color("#0085ff")

		if bucket_index == your_bucket_index:
			bar.color = Color("#ff0034")

	lower_bound_label.text = str(lowest)
	upper_bound_label.text = str(highest)