class_name Welder
extends Area3D

@export var weld_interval: float = 0.2
@export var min_distance: float = 0.2


@export var radius: float = 0.25

@export_category("Energy")
@export var max_energy: float = 100.0
@export var energy_per_second: float = 10.0
@export var recharge_ticks_per_second: float = 10.0
@export var energy_per_weld: float = 5.0

var _current_energy: float
@onready var _timer: Timer = $Timer
@onready var _recharge_timer: Timer = $RechargeTimer
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D

var is_welding:
	get: return not _timer.is_stopped()

func _ready():
	_collision_shape.shape.radius = radius
	_current_energy = max_energy
	_timer.timeout.connect(_weld)
	_recharge_timer.wait_time = 1.0 / recharge_ticks_per_second
	_recharge_timer.timeout.connect(_recharge)

func start_welding() -> void:
	_timer.wait_time = weld_interval
	_timer.start()
	_weld()

func stop_welding() -> void:
	_timer.stop()

func _weld() -> void:
	if _current_energy < energy_per_weld:
		print("not enough energy to weld")
		return
	_current_energy -= energy_per_weld
	var overlapping_bodies := get_overlapping_bodies()
	var weldable_bodies := overlapping_bodies.filter(func(body):
		return body.is_in_group("weldable"))
	print("found weldable bodies: ", str(weldable_bodies.size()))
	match weldable_bodies.size():
		0: pass
		1: WeldSpot.create(weldable_bodies[0], global_position, radius)
		_:
			var weld_spot := WeldSpot.create(weldable_bodies[0], global_position, radius)
			weld_spot.weld_to(weldable_bodies[1])

func _recharge() -> void:
	if is_welding:
		return
	var delta := 1.0 / recharge_ticks_per_second
	_current_energy = min(_current_energy + energy_per_second * delta, max_energy)
