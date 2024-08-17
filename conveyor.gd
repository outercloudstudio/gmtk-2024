extends Node2D


@export var rotation_origin: Node2D

@export var forward_sprite: Sprite2D
@export var right_sprite: Sprite2D
@export var left_sprite: Sprite2D


var _direction: Vector2i = Vector2i.RIGHT
var _facing: Vector2i = Vector2i.RIGHT


func place(direction: Vector2i, facing: Vector2i):
	_direction = direction
	_facing = facing

	forward_sprite.visible = false
	left_sprite.visible = false
	right_sprite.visible = false

	rotation_origin.look_at(global_position + Vector2.ONE * 8 + Vector2(direction))
	
	if Vector2i(direction.y, -direction.x) == facing:
		# left

		left_sprite.visible = true

		pass
	elif  Vector2i(-direction.y, direction.x) == facing:
		# right

		right_sprite.visible = true

		pass
	else:
		# foward

		forward_sprite.visible = true

		pass