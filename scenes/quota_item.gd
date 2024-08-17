extends Control
class_name QuotaItem


@export var texture_map: Dictionary


var identifier: String = "rod"
var amount: int = 10


func setup():
	$Control/TextureRect.texture = texture_map[identifier]
	$Label.text = "x" + str(amount)