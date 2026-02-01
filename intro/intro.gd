extends Node

const GAME_SCENE := "res://run_river_run.tscn"

@onready var animation: AnimationPlayer = $Animation

func _input(event: InputEvent):
	# if escape is pressed, speed up the intro
	var key_event := event as InputEventKey
	if key_event and key_event.pressed and key_event.keycode == Key.KEY_ESCAPE:
		animation.speed_scale = 20.0

func _switch_to_game_scene():
	get_tree().change_scene_to_file(GAME_SCENE)
