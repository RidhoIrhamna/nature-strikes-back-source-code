extends AudioStreamPlayer

# Music tracks - can be changed in the editor
@export var intro_music: AudioStream
@export var gameplay_music: AudioStream
@export var win_music: AudioStream
@export var lose_music: AudioStream

var current_track: String = ""

func _ready():
	# Enable looping for all music
	finished.connect(_on_finished)

# Play music by track name
func play_music(track_name: String):
	# Don't restart if already playing the same track
	if current_track == track_name and playing:
		return
	
	current_track = track_name
	
	match track_name:
		"intro":
			stream = intro_music
		"gameplay":
			stream = gameplay_music
		"win":
			stream = win_music
		"lose":
			stream = lose_music
		_:
			push_error("Unknown music track: " + track_name)
			return
	
	if stream:
		play()
	else:
		push_error("Music track '%s' not assigned!" % track_name)

# Stop music
func stop_music():
	stop()
	current_track = ""

func _on_finished():
	# Loop the current track
	if stream:
		play()
