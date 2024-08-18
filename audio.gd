extends Node
class_name Audio


@export var place_sounds: Array = []
@export var explosion_sounds: Array = []
var fire_play_count = 0


func _ready() -> void:
    Static.audio = self


func play(sound_name: String):
    var sound = null
    var player = AudioStreamPlayer2D.new()

    if sound_name == "place":
        sound = place_sounds.pick_random()
        player.volume_db = 15

    if sound_name == "explosion":
        sound = explosion_sounds.pick_random()
        player.volume_db = 3


    player.stream = sound
    player.attenuation = 0
    player.panning_strength = 0

    add_child(player)
    player.play()

    # await get_tree().create_timer(1).timeout

    # player.queue_free()


func play_fire():
    if fire_play_count == 0:
        $Fire.playing = true

    fire_play_count += 1 


func stop_fire():
    fire_play_count -= 1

    
    if fire_play_count == 0:
        $Fire.playing = false