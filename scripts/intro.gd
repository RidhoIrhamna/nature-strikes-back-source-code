extends Control

@onready var background: TextureRect = $Background
@onready var character_center: TextureRect = $CharacterCenter
@onready var speaker_label: Label = $DialogBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialog_label: Label = $DialogBox/MarginContainer/VBoxContainer/DialogLabel
@onready var continue_label: Label = $DialogBox/MarginContainer/VBoxContainer/ContinueLabel
@onready var skip_button: Button = $SkipButton

# Dialog data structure: [speaker, text, background_path]
# To change backgrounds: Replace the image paths below with your own assets
# Example: "res://assets/backgrounds/forest.png"
# You can use different images for each dialog or reuse the same one
var dialogs = [
	["-This old forest gives life to all creatures-", "res://assets/sprites/Tes Envi.png"],
	["-People are happy and peaceful-", "res://assets/sprites/Tes Envi.png"],
	["-Animals are also happy and peaceful-", "res://assets/sprites/Tes Envi.png"],
	["Anomaly", "Hello, everyone. I have come to bring light to you!", "res://assets/sprites/Tes Envi.png"],
	["-People are surprised and confused -", "res://assets/sprites/Tes Envi.png"],
	["Anomaly", "This forest is vast but in vain, imagine progress,jobs, food, better wealth!", "res://assets/sprites/Tes Envi.png"],
 	["People", "if this is for everyone's sake I believe him!", "res://assets/sprites/Tes Envi.png"],
	["Anomaly", "you deserve more!", "res://assets/sprites/Tes Envi.png"],
	[".......", "res://assets/sprites/Tes Envi.png"],
]
var current_dialog_index = 0
var is_typing = false

func _ready():
	skip_button.pressed.connect(_on_skip_pressed)
	
	# Play intro music
	var music = get_node_or_null("/root/Music")
	if music:
		music.play_music("intro")
	
	show_dialog(current_dialog_index)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_typing:
			next_dialog()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if not is_typing:
			next_dialog()

func show_dialog(index: int):
	if index >= dialogs.size():
		# End of intro, go to game
		get_tree().change_scene_to_file("res://scenes/game.tscn")
		return
	
	var dialog = dialogs[index]
	
	# Hide character first
	character_center.visible = false
	
	# Handle different dialog formats
	if dialog.size() == 2:
		# Format: [text, background_path] - no speaker
		speaker_label.visible = false
		dialog_label.text = dialog[0]
		# Show Pohon Suci as default narrator
		character_center.visible = true
		character_center.texture = load("res://assets/ui/POHONSUCI.png")
		# Change background if path is provided
		if dialog[1] != "":
			var texture = load(dialog[1])
			if texture:
				background.texture = texture
	else:
		# Format: [speaker, text, background_path]
		speaker_label.visible = true
		speaker_label.text = dialog[0]
		dialog_label.text = dialog[1]
		
		# Show character based on speaker
		var speaker_name = dialog[0].to_lower()
		if "anomal" in speaker_name:
			character_center.visible = true
			character_center.texture = load("res://assets/ui/Asset 2mafia.png")
		elif "pohon" in speaker_name or "nature" in speaker_name or "forest" in speaker_name:
			character_center.visible = true
			character_center.texture = load("res://assets/ui/POHONSUCI.png")
		
		# Change background if path is provided
		if dialog.size() > 2 and dialog[2] != "":
			var texture = load(dialog[2])
			if texture:
				background.texture = texture

func next_dialog():
	current_dialog_index += 1
	show_dialog(current_dialog_index)

func _on_skip_pressed():
	Sfx.play_click()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
