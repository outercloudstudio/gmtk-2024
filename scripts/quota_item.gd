extends Control
class_name QuotaItem


@export var texture_map: Dictionary


var identifier: String = "rod"
var amount: int = 10
var color: Color = Color("#ffffffff")


func setup():
	$Control/TextureRect.texture = texture_map[identifier]
	$Label.text = "x " + str(amount)
	$Label.modulate = color