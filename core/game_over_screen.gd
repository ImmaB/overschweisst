class_name GameOverScreen
extends PanelContainer

@onready var button:  Button = $CenterContainer/VBoxContainer/Button
@onready var button2: Button = $CenterContainer/VBoxContainer/Button2

func _ready() -> void:
	button.pressed.connect(_retry)
	button2.pressed.connect(_restart)
	get_tree().paused = true
	GameManager.player_characters.clear()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weld"):
		_retry()
	if event.is_action_pressed("back"):
		_restart()
	var key_event := event as InputEventKey
	if key_event and key_event.pressed and key_event.keycode == Key.KEY_ESCAPE:
		get_tree().quit()

func _retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://intro/intro.tscn")
