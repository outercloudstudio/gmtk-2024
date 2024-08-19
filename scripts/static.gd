extends Node


var quota = {}
var collected_quota = {}
var all_collected = {}
var score = 0

var items = {}

var state = "menu"

var item_levels = [
    [ "rod", "wire" ],
    [ "sheet", "lightbulb" ],
    [ "terminal", "button", "jeyboard" ],
]

var camera: Camera

var audio: Audio