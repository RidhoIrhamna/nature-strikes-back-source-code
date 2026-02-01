extends Control

@onready var start_button: Button = $TitleContainer/StartButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	# Play intro music
	var music = get_node_or_null("/root/Music")
	if music:
		music.play_music("intro")

func _on_start_pressed():
	Sfx.play_click()
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
