extends Camera2D


var smoothed_position = Vector2.ZERO

var original_position

func _ready() -> void:
	original_position = global_position

	smoothed_position = original_position


func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)



func _process(delta: float) -> void:
	# var mouse_offset = original_position - get_global_mouse_position()

	# smoothed_position = fixed_lerp(smoothed_position, original_position + -mouse_offset * 0.05, 99999, delta)

	# global_position = smoothed_position

	var snapping_nodes = get_tree().get_nodes_in_group("camera_snapping")

	for nodes: Node2D in snapping_nodes:
		var sprite_offset = nodes.get_parent().global_position - global_position

		sprite_offset = round(sprite_offset)

		nodes.global_position = global_position + sprite_offset

	pass