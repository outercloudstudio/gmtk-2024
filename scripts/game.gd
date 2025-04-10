extends Node2D
class_name Game


@export var world: World
@export var timer_progress: TextureProgressBar
@export var performance_label: Label
@export var quota_holder: Node2D
@export var quota_item_scene: PackedScene
@export var ordered_level_scenes: Array
@export var level_scenes: Array
@export var tutorial_level_scene: PackedScene
@export var main_menu_animation_player: AnimationPlayer
@export var results_menu_animation_player: AnimationPlayer
@export var lower_bound_label: Label
@export var upper_bound_label: Label
@export var graph: Control
@export var background: ColorRect
@export var collected_holder: Control
@export var results_menu_mid_animation_player: AnimationPlayer
@export var tutorial_animator: AnimationPlayer
@export var quota_label: Label
@export var quota_failed: TextureRect
@export var quota_passed: TextureRect
@export var quota_state_aniamtor: AnimationPlayer

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
var _hiding_quota = false
var _show_quota_label = false

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
	if _show_quota_label:
		quota_label.modulate = Color(quota_label.modulate.r, quota_label.modulate.g, quota_label.modulate.b, fixed_lerp(quota_label.modulate.a, 1, 4, delta))
	else:
		quota_label.modulate = Color(quota_label.modulate.r, quota_label.modulate.g, quota_label.modulate.b, fixed_lerp(quota_label.modulate.a, 0, 4, delta))

	if Static.state == "play":
		if !Static.is_tutorial || Static.tutorial_stage == "finish":
			_round_timer -= delta

		timer_progress.value = _round_timer / 80 * 100

		if Static.tutorial_stage == "finish":
			timer_progress.value = _round_timer / 20 * 100

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

	performance_label.scale = fixed_lerp(performance_label.scale, Vector2.ONE, 8, delta)
	performance_label.modulate = fixed_lerp(performance_label.modulate, Color("#ffffff"), 8, delta)


func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)


func start_round():
	Static.state = "play"

	_round_timer = 80
	_rung = false
	_show_quota_label = true

	var level = world.start(_level_scene)

	Static.quota = level.quota
	Static.score = 0

	Static.collected_quota = {}
	Static.all_collected = {}

	for identifier in Static.quota:
		Static.collected_quota[identifier] = 0

	Static.audio.music_state = "play"

	_current_level_identifier = level.scene_file_path.get_file()

	_start_quota_display()

	await get_tree().create_timer(1).timeout
	
	_scores = await fetch_scores(_current_level_identifier)


func end_round():
	Static.state = "results"

	var just_tutorial = Static.is_tutorial

	Static.is_tutorial = false
	Static.tutorial_stage = "none"

	performance_label.text = "0"

	results_menu_animation_player.play("show")

	for item in Static.all_collected:
		if Static.quota.has(item):
			Static.score += 100 * Static.all_collected[item]
		else:
			Static.score -= 50 * Static.all_collected[item]

	if Static.score < 0:
		Static.score = 0

	var failed = false

	for item in Static.quota:
		if Static.quota[item] - Static.collected_quota[item] > 0:
			failed = true
			
			break
	
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

	quota_failed.visible = failed
	quota_passed.visible = !failed

	await get_tree().create_timer(0.5).timeout

	quota_state_aniamtor.play("show")

	await get_tree().create_timer(0.4 - 0.368 - 0.08).timeout

	Static.audio.play("land")

	await get_tree().create_timer(2 - (0.4 - 0.368 - 0.08)).timeout

	var totaled_score = 0

	for item in Static.all_collected:
		var quota_item: QuotaItem = quota_item_scene.instantiate()

		collected_holder.add_child(quota_item)

		quota_item.identifier = item
		quota_item.color = Color("#00ff00")

		if !Static.quota.has(item):
			quota_item.color = Color("#ff0000")

		quota_item.setup()

		if collected_holder.get_child_count() > 4:
			collected_holder.get_child(0).free()

		var index = 0

		for i in range(Static.all_collected[item]):
			if Static.quota.has(item):
				Static.audio.play_pitched("boop", 0.6 + i * 0.05)
			else:
				Static.audio.play_pitched("boop", 1.6 - i * 0.015)

			quota_item.amount = i + 1
			quota_item.color = Color("#00ff00")

			if index % 5 == 0:
				performance_label.modulate = Color("#00ff00")

			if !Static.quota.has(item):
				quota_item.color = Color("#ff0000")

				if index % 5 == 0:
					performance_label.modulate = Color("#ff0000")

				totaled_score -= 50
			else:
				totaled_score += 100

			performance_label.text = str(totaled_score)

			if totaled_score < 0:
				performance_label.text = "0"

			if index % 5 == 0:
				performance_label.scale = Vector2(1.5, 1.5)

			quota_item.setup()

			index += 1

			await get_tree().create_timer(0.02).timeout

		await get_tree().create_timer(0.75).timeout

	await get_tree().create_timer(1).timeout

	if !just_tutorial:
		results_menu_mid_animation_player.play("graph")


func start():
	if len(ordered_level_scenes) > 0:
		_level_scene = ordered_level_scenes[0]
		ordered_level_scenes.remove_at(0)
	else:
		_level_scene = level_scenes.pick_random()

	main_menu_animation_player.play("hide")

	start_round()


func restart():
	_hide_quota_display()

	results_menu_animation_player.play("hide")

	start_round()


func next():
	_hide_quota_display()

	if len(ordered_level_scenes) > 0:
		_level_scene = ordered_level_scenes[0]
		ordered_level_scenes.remove_at(0)
	else:
		_level_scene = level_scenes.pick_random()

	results_menu_animation_player.play("hide")

	start_round()


func tutorial():
	Static.is_tutorial = true

	Static.tutorial_stage = "start"

	_level_scene = tutorial_level_scene
	main_menu_animation_player.play("hide")

	tutorial_animator.play("start")

	start_round()


func tutorial_splitter_stage():
	Static.tutorial_stage = "splitter"

	tutorial_animator.play("splitter")


func tutorial_repairing_stage():
	Static.tutorial_stage = "repairing"

	tutorial_animator.play("repairing")

	Static.tutorial_repair_count = 0


func tutorial_constructor_stage():
	Static.tutorial_stage = "constructor"

	tutorial_animator.play("constructor")


func tutorial_producing_stage():
	Static.tutorial_stage = "producing"

	tutorial_animator.play("producing")


func tutorial_deleting_stage():
	Static.tutorial_stage = "deleting"

	tutorial_animator.play("deleting")


func tutorial_finish_stage():
	Static.tutorial_stage = "finish"

	tutorial_animator.play("finish")

	_round_timer = 20


func menu():
	_hide_quota_display()
	_show_quota_label = false

	results_menu_animation_player.play("hide")

	main_menu_animation_player.play("show")

	Static.state = "menu"

	Static.audio.music_state = "menu"


func _start_quota_display():
	while _hiding_quota:
		await get_tree().create_timer(0.1).timeout

	var index = 0

	for identifier in Static.quota:
		var quota_item: QuotaItem = quota_item_scene.instantiate()
		quota_holder.add_child(quota_item)

		quota_item.identifier = identifier
		quota_item.amount = Static.quota[identifier] - Static.collected_quota[identifier]

		quota_item.position = Vector2(0, 20 * index)

		quota_item.setup()

		index += 1

		await get_tree().create_timer(0.1).timeout


func _update_quota_display():
	if _hiding_quota:
		return

	var index = 0

	for identifier in Static.quota:
		if quota_holder.get_child_count() <= index:
			return

		var quota_item: QuotaItem = quota_holder.get_child(index)

		quota_item.amount = Static.quota[identifier] - Static.collected_quota[identifier]

		quota_item.setup()

		index += 1


func _hide_quota_display():
	_hiding_quota = true

	for child in quota_holder.get_children():
		child.get_node("AnimationPlayer").play("hide")

		await get_tree().create_timer(0.1).timeout

	await get_tree().create_timer(0.4).timeout

	for child in quota_holder.get_children():
		child.free()

	_hiding_quota = false


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
