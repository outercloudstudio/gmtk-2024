extends Node
class_name Audio


@export var place_sounds: Array = []
@export var click_sounds: Array = []
@export var repair_sounds: Array = []
@export var explosion_sounds: Array = []
@export var destroy_sounds: Array = []
@export var spawn_sounds: Array = []
var fire_play_count = 0
var music_state = "menu"


func _ready() -> void:
    Static.audio = self


func _process(delta: float) -> void:
    if music_state == "menu":
        $Menu.volume_db = fixed_lerp($Menu.volume_db, 0, 4, delta)
        $Play.volume_db = fixed_lerp($Play.volume_db, -30, 4, delta)
        $PlayIntense.volume_db = fixed_lerp($PlayIntense.volume_db, -30, 4, delta)
        $Finish.volume_db = fixed_lerp($Finish.volume_db, -30, 4, delta)

    if music_state == "play":
        $Menu.volume_db = fixed_lerp($Menu.volume_db, -30, 4, delta)
        $Play.volume_db = fixed_lerp($Play.volume_db, 0, 4, delta)
        $PlayIntense.volume_db = fixed_lerp($PlayIntense.volume_db, -30, 4, delta)
        $Finish.volume_db = fixed_lerp($Finish.volume_db, -30, 4, delta)

    if music_state == "play_intense":
        $Menu.volume_db = fixed_lerp($Menu.volume_db, -30, 4, delta)
        $Play.volume_db = move_toward($Play.volume_db, -30, delta * 10)
        $PlayIntense.volume_db = move_toward($PlayIntense.volume_db, 0, delta * 30)
        $Finish.volume_db = fixed_lerp($Finish.volume_db, -30, 4, delta)

    if music_state == "finish":
        $Menu.volume_db = fixed_lerp($Menu.volume_db, -30, 4, delta)
        $Play.volume_db = fixed_lerp($Play.volume_db, -30, 4, delta)
        $PlayIntense.volume_db = fixed_lerp($PlayIntense.volume_db, -30, 4, delta)
        $Finish.volume_db = fixed_lerp($Finish.volume_db, 0, 4, delta)


func fixed_lerp(a, b, decay, delta):
    return b + (a - b) * exp(-decay * delta)


func play(sound_name: String):
    var sound = null
    var player = AudioStreamPlayer2D.new()

    if sound_name == "place":
        sound = place_sounds.pick_random()
        player.volume_db = 18
        player.pitch_scale = randf_range(0.9, 1.1)

    if sound_name == "repair":
        sound = repair_sounds.pick_random()
        player.volume_db = 3
        player.pitch_scale = randf_range(0.9, 1.1)

    if sound_name == "destroy":
        sound = destroy_sounds.pick_random()
        player.volume_db = 4
        player.pitch_scale = randf_range(0.9, 1.1)

    if sound_name == "explosion":
        sound = explosion_sounds.pick_random()
        player.volume_db = 3
        player.pitch_scale = randf_range(0.9, 1.1)

    if sound_name == "spawn":
        sound = spawn_sounds.pick_random()
        player.volume_db = 2
        player.pitch_scale = randf_range(0.9, 1.1)

    if sound_name == "click":
        sound = click_sounds.pick_random()
        player.volume_db = 7
        player.pitch_scale = randf_range(0.9, 1.1)

    player.stream = sound
    player.attenuation = 0
    player.panning_strength = 0

    add_child(player)
    player.play()

    await get_tree().create_timer(1).timeout

    player.queue_free()


func play_fire():
    if fire_play_count == 0:
        $Fire.playing = true

    fire_play_count += 1 


func stop_fire():
    fire_play_count -= 1

    if fire_play_count == 0:
        $Fire.playing = false