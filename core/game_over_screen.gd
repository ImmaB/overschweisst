class_name GameOverScreen
extends PanelContainer

@onready var button: Button = $CenterContainer/VBoxContainer/Button


func _ready() -> void:
    button.pressed.connect(_retry)
    get_tree().paused = true

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("weld"):
        _retry()

func _retry() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()