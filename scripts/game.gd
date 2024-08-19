extends Node2D
class_name Game


@export var world: World
@export var timer_progress: TextureProgressBar
@export var performance_label: Label
@export var quota_holder: Node2D
@export var quota_item_scene: PackedScene
@export var level_scenes: Array
@export var main_menu_animation_player: AnimationPlayer
@export var results_menu_animation_player: AnimationPlayer
@export var lower_bound_label: Label
@export var upper_bound_label: Label
@export var graph: Control
@export var background: ColorRect
@export var collected_holder: Control
@export var results_menu_mid_animation_player: AnimationPlayer

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

var _round_timer = 0
var _level_scene = null
var _scores = []
var _current_level_identifier = "none"
var _rung = false

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


func _ready() -> void:
	Firebase.Auth.login_anonymous()

	timer_progress.value = 0


func _process(delta: float) -> void:
	if Static.state == "play":
		_round_timer -= delta

		timer_progress.value = _round_timer / 80 * 100

		_update_quota_display()

		if _round_timer <= 15:
			Static.audio.music_state = "play_intense"

			if !_rung:
				_rung = true

				Static.audio.play("ring")

		if _round_timer <= 0:
			end_round()

	if Static.state == "play" && _round_timer <= 15:
		background.material.set_shader_parameter("danger", fixed_lerp(background.material.get_shader_parameter("danger"), 1, 2, delta))
	else:
		background.material.set_shader_parameter("danger", fixed_lerp(background.material.get_shader_parameter("danger"), 0, 2, delta))


func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)


func start_round():
	Static.state = "play"

	_round_timer = 80
	_rung = false

	var level = world.start(_level_scene)

	Static.quota = level.quota
	Static.score = 0

	Static.collected_quota = {}
	Static.all_collected = {}

	for identifier in Static.quota:
		Static.collected_quota[identifier] = 0

	Static.audio.music_state = "play"

	_current_level_identifier = level.scene_file_path.get_file()

	await get_tree().create_timer(1).timeout
	
	_scores = await fetch_scores(_current_level_identifier)



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

	var score_data = []

	for score in _scores:
		score_data.push_back(score)

	score_data.push_back(Static.score)

	draw_graph(score_data, Static.score)

	if !failed:
		submit_score(_current_level_identifier, Static.score)

	results_menu_mid_animation_player.play("RESET")
	results_menu_mid_animation_player.seek(0.1, true)

	for child in collected_holder.get_children():
		child.free()

	await get_tree().create_timer(0.5).timeout

	for item in Static.all_collected:
		var quota_item: QuotaItem = quota_item_scene.instantiate()

		collected_holder.add_child(quota_item)

		quota_item.identifier = item
		quota_item.setup()

		if collected_holder.get_child_count() > 4:
			collected_holder.get_child(0).free()

		for i in range(Static.all_collected[item]):
			Static.audio.play_pitched("boop", 0.6 + i * 0.05)

			quota_item.amount = i + 1
			quota_item.setup()

			await get_tree().create_timer(0.05).timeout

		await get_tree().create_timer(1).timeout

	results_menu_mid_animation_player.play("graph")


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

	var index = 0

	for identifier in Static.quota:
		var quota_item: QuotaItem = quota_item_scene.instantiate()
		quota_holder.add_child(quota_item)

		quota_item.identifier = identifier
		quota_item.amount = Static.quota[identifier] - Static.collected_quota[identifier]

		quota_item.position = Vector2(0, 20 * index)

		quota_item.setup()

		index += 1


func draw_graph(data: Array, your_score):
	var lowest = your_score
	var highest = your_score

	var graph_width = floor(graph.size.x / 4 - 1)

	for score in data:
		lowest = min(lowest, score)
		highest = max(highest, score)

	var bucket_size = (highest - lowest) / (graph_width)

	if bucket_size == 0:
		bucket_size = 1

	var buckets = []

	for x in range(graph_width + 1):
		buckets.push_back(0)

	for score in data:
		var bucket = round((score - lowest) / bucket_size)

		buckets[bucket] += 1

		if bucket - 1 >= 0:
			buckets[bucket - 1] += 0.4

		if bucket - 2 >= 0:
			buckets[bucket - 2] += 0.1

		if bucket + 1 <= graph_width:
			buckets[bucket + 1] += 0.4

		if bucket + 2 <= graph_width:
			buckets[bucket + 2] += 0.1

	var max_count = 0

	for mode in buckets:
		max_count = max(max_count, mode)

	for child in graph.get_children():
		child.queue_free()

	var your_bucket_index = round((your_score - lowest) / bucket_size)

	for bucket_index in range(len(buckets)):
		var bar = ColorRect.new()

		var height = graph.size.y

		if max_count != 0:
			height = floor(graph.size.y * buckets[bucket_index] / max_count)

		graph.add_child(bar)
		bar.position = Vector2(bucket_index * 4, graph.size.y - height)
		bar.size = Vector2(4, height)

		bar.color = Color("#0085ff")

		if bucket_index == your_bucket_index:
			bar.color = Color("#ff0034")

	lower_bound_label.text = str(lowest)
	upper_bound_label.text = str(highest)


func fetch_scores(level: String):
	var scores = []

	var query: FirestoreQuery = FirestoreQuery.new()

	query.from("data")
	query.limit(10)

	var results = await Firebase.Firestore.query(query)
	var result = null

	for other_result in results:
		if other_result.doc_name == level:
			result = other_result

	if result == null:
		print("Missing level document")

		return []

	if result.is_null_value("scores"):
		print("Missing scores")

		return []

	var level_data = result.get_value("scores")

	if !(level_data is Dictionary):
		print("data is not disctionary")

		return []

	if !level_data.has("values"):
		print("Missing values")

		return []

	var scores_data = level_data["values"]

	for data in scores_data:
		if data.has("integerValue"):
			var value = data["integerValue"]

			if value.is_valid_float():
				scores.append(float(value))

		if data.has("doubleValue"):
			scores.append(data["doubleValue"])

	return scores


func submit_score(level: String, score):
	var collection: FirestoreCollection = Firebase.Firestore.collection("data")

	var scores = []

	var query: FirestoreQuery = FirestoreQuery.new()

	query.from("data")
	query.limit(10)

	var results = await Firebase.Firestore.query(query)
	var result = null

	for other_result in results:
		if other_result.doc_name == level:
			result = other_result

	if result == null:
		print("Missing level document")

		return

	if result.is_null_value("scores"):
		print("Missing scores")
	else:
		var level_data = result.get_value("scores")

		if !(level_data is Dictionary):
			print("data is not disctionary")
		else:
			if !level_data.has("values"):
				print("Missing values")
			else:
				var scores_data = level_data["values"]

				for data in scores_data:
					if data.has("integerValue"):
						var value = data["integerValue"]

						if value.is_valid_float():
							scores.append(float(value))

					if data.has("doubleValue"):
						scores.append(data["doubleValue"])


	scores.push_back(score)

	result.add_or_update_field("scores", scores)
	
	await collection.update(result) 
