extends Camera2D


func _process(delta: float) -> void:
	var snapping_nodes = get_tree().get_nodes_in_group("camera_snapping")

	for nodes: Node2D in snapping_nodes:
		var sprite_offset = nodes.get_parent().global_position - global_position

		sprite_offset = round(sprite_offset)

		nodes.global_position = global_position + sprite_offset

	pass