class_name GameOverScreen
extends PanelContainer

@onready var button: Button = $CenterContainer/VBoxContainer/Button


func _ready() -> void:
    button.pressed.connect(_retry)


func _retry() -> void:
    get_tree().reload_current_scene()