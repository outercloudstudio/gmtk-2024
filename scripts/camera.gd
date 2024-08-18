extends Camera2D
class_name Camera


var smoothed_position = Vector2.ZERO

var original_position

var shake_timer = 0
var shake_direction = Vector2.RIGHT
var shake_position
var shake_intensity = 0

func _ready() -> void:
	original_position = global_position

	smoothed_position = original_position

	Static.camera = self


func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)



func _process(delta: float) -> void:
	shake_timer -= delta
	
	if shake_timer <= 0:
		shake_timer = randf_range(0.015, 0.03)

		shake_direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))

	shake_position = shake_direction * pow(shake_intensity * 2, 1.5)

	shake_intensity = fixed_lerp(shake_intensity, 0, 14, delta)

	var mouse_offset = original_position - get_global_mouse_position()

	smoothed_position = fixed_lerp(smoothed_position, original_position + -mouse_offset * 0.02, 99999, delta)

	global_position = smoothed_position + shake_position

	var snapping_nodes = get_tree().get_nodes_in_group("camera_snapping")

	for nodes: Node2D in snapping_nodes:
		var sprite_offset = nodes.get_parent().global_position - global_position

		sprite_offset = round(sprite_offset)

		nodes.global_position = global_position + sprite_offset

	pass


func shake(intensity):
	shake_intensity = max(intensity, shake_intensity)
