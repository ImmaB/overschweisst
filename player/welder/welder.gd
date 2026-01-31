class_name Welder
extends Area3D

const WELD_SPOT_SCENE: PackedScene = preload("res://player/welder/weld_spot.tscn")

@export var weld_interval: float = 0.2
@onready var _timer: Timer = $Timer
var is_welding:
	get: return not _timer.is_stopped()

func _ready():
	_timer.timeout.connect(_weld)

func start_welding() -> void:
	_timer.wait_time = weld_interval
	_timer.start()
	_weld()

func stop_welding() -> void:
	_timer.stop()

func _weld() -> void:
	var overlapping_bodies := get_overlapping_bodies()
	var weldable_bodies := overlapping_bodies.filter(func(body):
		return body.is_in_group("weldable"))
	print("found weldable bodies: ", str(weldable_bodies.size()))
	match weldable_bodies.size():
		0: pass
		1: _create_weld_spot()
		_:
			var weld_spot := _create_weld_spot()
			weld_spot.weld_bodies(weldable_bodies[0], weldable_bodies[1])

func _create_weld_spot() -> WeldSpot:
	var weld_spot: WeldSpot = WELD_SPOT_SCENE.instantiate()
	get_tree().current_scene.add_child(weld_spot)
	weld_spot.global_position = global_position
	return weld_spot
