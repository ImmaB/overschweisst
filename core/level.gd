class_name Level
extends Node

const PLAYER_CAMERA := preload("res://camera/player_camera.tscn")

@export var survival_duration: float = 30.0

var _win_timer: Timer

func _ready():
	var camera: PlayerCamera = PLAYER_CAMERA.instantiate()
	add_child(camera)
	var player_characters := GameManager.player_characters
	camera.set_targets(player_characters)
	_win_timer = Timer.new()
	_win_timer.wait_time = survival_duration
	_win_timer.one_shot = true
	_win_timer.timeout.connect(_on_win_timer_timeout)
	add_child(_win_timer)
	_win_timer.start()

func _on_win_timer_timeout() -> void:
	GameManager.platform_generator.spawn_end_platform()
