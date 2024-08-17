extends Area2D


@export var tile: Node2D

var process_queue = []
var last_items_to_send = []
var items_to_output = []
var produce_timer = 0

func rotation_to_vector(rotation: float) -> Vector2:
	if rotation == 0:
		return Vector2.RIGHT
	
	if rotation == -180:
		return Vector2.LEFT

	if rotation == -90:
		return Vector2.UP

	if rotation == 90:
		return Vector2.DOWN

	return Vector2.ZERO


func _physics_process(delta: float) -> void:
	var tile_position = Vector2i(floor(tile.global_position / 16))

	var foward = rotation_to_vector(global_rotation_degrees)

	var items_to_send = []

	for item: CharacterBody2D in get_tree().get_nodes_in_group("item"):
		var item_tile_position = Vector2i(floor(item.global_position / 16))
		
		if item_tile_position != tile_position:
			continue

		if last_items_to_send.has(item):
			items_to_send.push_back(item)

		if !items_to_send.has(item):
			if process_queue.has(item):
				continue

			process_queue.push_back(item)
		else:
			var velocity = foward

			if foward == Vector2.RIGHT || foward == Vector2.LEFT:
				if abs(item.global_position.y - global_position.y) > 1:
					if item.global_position.y < global_position.y:
						velocity += Vector2.DOWN
					else:
						velocity += Vector2.UP
			else:
				if abs(item.global_position.x - global_position.x) > 1:
					if item.global_position.x < global_position.x:
						velocity += Vector2.RIGHT
					else:
						velocity += Vector2.LEFT

			item.velocity = velocity.normalized() * 50

	if len(process_queue) > 0:
		while !is_instance_valid(process_queue[0]):
			process_queue.remove_at(0)

	if len(process_queue) > 0 && len(items_to_output) == 0:
		var possible_recipes = [
			{ 
				ingredients = ["sheet"],
				result = ["rod", "rod"]
			},
			{ 
				ingredients = ["lightbulb"],
				result = ["rod", "battery"],
			},
			{ 
				ingredients = ["button"],
				result = ["battery", "sheet"],
			},
			{ 
				ingredients = ["terminal"],
				result = ["sheet", "lightbulb"],
			},
			{ 
				ingredients = ["keyboard"],
				result = ["sheet", "button"],
			},
			{ 
				ingredients = ["rod"],
				result = ["scrap", "scrap"],
			},
			{ 
				ingredients = ["battery"],
				result = ["copper_bit", "copper_bit"],
			},
		]

		var result = null
		var items_consumed = 0

		for recipe in possible_recipes:
			items_consumed = 0

			var possible_recipe_items = []

			if len(recipe.ingredients) > len(process_queue):
				continue

			for index in range(len(recipe.ingredients)):
				possible_recipe_items.push_back(process_queue[index])

			for item in possible_recipe_items:
				if recipe.ingredients.has(item.identifier):
					recipe.ingredients.remove_at(recipe.ingredients.find(item.identifier))

					items_consumed += 1

			if len(recipe.ingredients) == 0:
				result = recipe.result

				break

		if result != null:
			for i in range(items_consumed):
				process_queue[0].queue_free()
				process_queue.remove_at(0)

			items_to_output = result
		else:
			process_queue[0].queue_free()
			process_queue.remove_at(0)

	produce_timer -= delta

	if produce_timer <= 0 and len(items_to_output) > 0:
		produce_timer = 0.25

		var result = items_to_output[0]
		items_to_output.remove_at(0)

		var scene = Static.items[result]

		var item: Node2D = scene.instantiate()

		tile.get_parent().add_child(item)
		item.global_position = global_position

		items_to_send.push_back(item)

	last_items_to_send = items_to_send