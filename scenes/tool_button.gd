extends Node2D


@export var texture: Texture2D
@export var is_enabled = false
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


func clicked() -> void:
	if !is_enabled:
		return

	on_clicked.emit()

	$SquashAndStretch.trigger(Vector2(0.6, 0.6), 12)
	
