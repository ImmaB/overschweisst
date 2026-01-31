class_name Welder
extends Area3D

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
		1: WeldSpot.create(weldable_bodies[0], global_position)
		_:
			var weld_spot := WeldSpot.create(weldable_bodies[0], global_position)
			weld_spot.weld_to(weldable_bodies[1])
