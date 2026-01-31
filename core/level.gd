class_name Level
extends Node

const PLAYER_CAMERA := preload("res://camera/player_camera.tscn")

func _ready():
    var camera: PlayerCamera = PLAYER_CAMERA.instantiate()
    add_child(camera)
    camera.set_target(get_node("PlayerCharacter"))