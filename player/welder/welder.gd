class_name Welder
extends Area3D

const WELD_SPARK = preload("res://player/welder/weld_spark.tscn")

@export var weld_interval: float = 0.2
@export var min_distance: float = 0.2
@export var empty_pitch: float = 2.0
@export var empty_db: float = -20.0


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
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

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
	audio_stream_player_3d.pitch_scale = 1.0
	audio_stream_player_3d.volume_db = 0.0
	audio_stream_player_3d.play()
	_weld()

func stop_welding() -> void:
	audio_stream_player_3d.stop()
	_timer.stop()

func _weld() -> void:
	var weld_spark: WeldSpark = WELD_SPARK.instantiate()
	get_tree().current_scene.add_child(weld_spark)
	weld_spark.global_position = global_position
	if _current_energy < energy_per_weld:
		weld_spark.spark(false)
		audio_stream_player_3d.pitch_scale = empty_pitch
		audio_stream_player_3d.volume_db = empty_db
		return
	weld_spark.spark(true)
	_current_energy -= energy_per_weld
	var overlapping_bodies := get_overlapping_bodies()
	var weldable_bodies := overlapping_bodies.filter(func(body):
		return body.is_in_group("weldable"))
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
