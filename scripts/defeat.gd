extends Control

@onready var character_center: TextureRect = $CharacterCenter
@onready var speaker_label: Label = $DialogBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var title_label: Label = $DialogBox/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $DialogBox/MarginContainer/VBoxContainer/MessageLabel
@onready var wave_label: Label = $DialogBox/MarginContainer/VBoxContainer/WaveLabel
@onready var narration_label: Label = $DialogBox/MarginContainer/VBoxContainer/NarrationLabel
@onready var button_container: HBoxContainer = $DialogBox/MarginContainer/VBoxContainer/ButtonContainer
@onready var restart_button: Button = $DialogBox/MarginContainer/VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button: Button = $DialogBox/MarginContainer/VBoxContainer/ButtonContainer/MenuButton

# Dialog format: [speaker, text] atau [text] (tanpa speaker)
var dialogs = [
	["The forest burns, the rivers run dry."],
	["Animals flee from their destroyed homes."],
	["Anomaly", "everything is mine, hahaha!"],
	["Nature is destroyed... but hope remains."],
	["Will you answer nature's call once more?"]
]

var current_dialog_index = 0
var dialogs_finished = false

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# Hide buttons initially
	button_container.visible = false
	
	# Play lose music
	var music = get_node_or_null("/root/Music")
	if music:
		music.play_music("lose")
	
	# Get wave info from game_manager if available
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		wave_label.text = "Waves Survived: %d/%d" % [game_manager.current_wave, game_manager.total_waves]
	
	# Start dialog
	show_dialog(current_dialog_index)

func _input(event):
	if dialogs_finished:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		next_dialog()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		next_dialog()

func show_dialog(index: int):
	if index >= dialogs.size():
		# End of dialogs, show buttons
		dialogs_finished = true
		character_center.visible = false
		speaker_label.visible = false
		title_label.visible = true
		message_label.visible = true
		wave_label.visible = true
		narration_label.visible = true
		button_container.visible = true
		return
	
	# Hide final screen elements during dialog
	title_label.visible = false
	message_label.visible = false
	wave_label.visible = false
	
	var dialog = dialogs[index]
	if dialog.size() == 1:
		speaker_label.visible = false
		narration_label.text = dialog[0]
		character_center.visible = true
		character_center.texture = load("res://assets/ui/POHONSUCI.png")
	else:
		speaker_label.visible = true
		speaker_label.text = dialog[0]
		narration_label.text = dialog[1]
		var speaker_name = dialog[0].to_lower()
		if "anomal" in speaker_name:
			character_center.visible = true
			character_center.texture = load("res://assets/ui/Asset 2mafia.png")
		elif "pohon" in speaker_name or "nature" in speaker_name:
			character_center.visible = true
			character_center.texture = load("res://assets/ui/POHONSUCI.png")
		else:
			character_center.visible = false
		narration_label.text = dialog[1]

func next_dialog():
	current_dialog_index += 1
	show_dialog(current_dialog_index)

func _on_restart_pressed():
	Sfx.play_click()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_pressed():
	Sfx.play_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
