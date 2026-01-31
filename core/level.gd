class_name Level
extends Node

const PLAYER_CAMERA := preload("res://camera/player_camera.tscn")

func _ready():
	var camera: PlayerCamera = PLAYER_CAMERA.instantiate()
	add_child(camera)
	var player_characters := GameManager.get_player_characters()
	camera.set_targets(player_characters)
