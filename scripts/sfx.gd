extends Node

# Sound effect players - can be changed in the editor
@export var click_sound: AudioStream
@export var hit_tower_sound: AudioStream
@export var notif_final_wave_sound: AudioStream
@export var serang_badak_sound: AudioStream
@export var serang_gajah_sound: AudioStream
@export var serang_macan_sound: AudioStream
@export var spawn_boss_sound: AudioStream
@export var spawn_bulldozer_sound: AudioStream
@export var mati_bulldozer_sound: AudioStream
@export var serang_bulldozer_sound: AudioStream
@export var serang_excavator_sound: AudioStream
@export var spawn_badak_sound: AudioStream
@export var spawn_gajah_sound: AudioStream
@export var spawn_macan_sound: AudioStream

# Audio players pool for overlapping sounds
var audio_players: Array[AudioStreamPlayer] = []
var max_players: int = 10
var next_player_index: int = 0

func _ready():
	# Create audio player pool
	for i in range(max_players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		audio_players.append(player)

# Play sound effect by name
func play(sound_name: String, volume_db: float = 0.0):
	var stream: AudioStream = null
	
	match sound_name:
		"click":
			stream = click_sound
		"hit_tower":
			stream = hit_tower_sound
		"notif_final_wave":
			stream = notif_final_wave_sound
		"serang_badak":
			stream = serang_badak_sound
		"serang_gajah":
			stream = serang_gajah_sound
		"serang_macan":
			stream = serang_macan_sound
		"spawn_boss":
			stream = spawn_boss_sound
		"spawn_bulldozer":
			stream = spawn_bulldozer_sound
		"mati_bulldozer":
			stream = mati_bulldozer_sound
		"serang_bulldozer":
			stream = serang_bulldozer_sound
		"serang_excavator":
			stream = serang_excavator_sound
		"spawn_badak":
			stream = spawn_badak_sound
		"spawn_gajah":
			stream = spawn_gajah_sound
		"spawn_macan":
			stream = spawn_macan_sound
		_:
			push_error("Unknown sound effect: " + sound_name)
			return
	
	if stream:
		_play_stream(stream, volume_db)
	else:
		push_error("Sound effect '%s' not assigned!" % sound_name)

# Internal function to play a stream using pooled players
func _play_stream(stream: AudioStream, volume_db: float = 0.0):
	var player = audio_players[next_player_index]
	player.stream = stream
	player.volume_db = volume_db
	player.play()
	
	# Move to next player (circular buffer)
	next_player_index = (next_player_index + 1) % max_players

# Convenience functions for common sounds
func play_click():
	play("click")

func play_hit_tower():
	play("hit_tower")

func play_notif_final_wave():
	play("notif_final_wave")

func play_serang_badak():
	play("serang_badak")

func play_serang_gajah():
	play("serang_gajah")

func play_serang_macan():
	play("serang_macan")

func play_spawn_boss():
	play("spawn_boss")

func play_spawn_bulldozer():
	play("spawn_bulldozer")

func play_mati_bulldozer():
	play("mati_bulldozer")

func play_serang_bulldozer():
	play("serang_bulldozer")

func play_serang_excavator():
	play("serang_excavator")

func play_spawn_badak():
	play("spawn_badak")

func play_spawn_gajah():
	play("spawn_gajah")

func play_spawn_macan():
	play("spawn_macan")
