extends Node2D


@export var texture: Texture2D
@export var is_enabled = false
@export var world: World
@export var identifier: String
@export var border_texture: Texture2D
@export var selected_border_texture: Texture2D
@export var border: Sprite2D
var _is_enabled_cache = false


signal on_clicked()


func _ready() -> void:
	$SquashTarget/TextureRect.texture = texture


func _process(_delta):
	if _is_enabled_cache != is_enabled:
		if is_enabled:
			$AnimationPlayer.play("show")
		else:
			$AnimationPlayer.play("hide")

		_is_enabled_cache = is_enabled

	if world.selected_tool_identifier == identifier:
		border.texture = selected_border_texture
	else:
		border.texture = border_texture


func clicked() -> void:
	if !is_enabled:
		return

	on_clicked.emit()

	$SquashAndStretch.trigger(Vector2(0.6, 0.6), 12)
	
