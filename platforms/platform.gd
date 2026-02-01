class_name Platform
extends RigidBody3D

@export var lifetime: float = 5.0
@export var _mass: float = 1.0
@export var base_volume: float = 20.0
@export var max_volume: float = 70.0
@export var sound_velocity_factor: float = 2.25
@export var sound_distance_factor: float = 2.25

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _timer: Timer = $Timer

var _touched_player: bool = false
var connected_platforms: Array[Platform] = []

func _ready():
	_timer.wait_time = lifetime
	_timer.start()
	_timer.timeout.connect(_start_melting)
	mass = _mass

func _start_melting() -> void:
	animation_player.play("melt")

func remove_forces() -> void:
	constant_force = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func _collision(body: Node) -> void:
	if not _touched_player and body is PlayerCharacter:
		_touched_player = true
		remove_forces()
	if body is Platform:
		var relative_velocity: Vector3 = to_local(body.linear_velocity) - to_local(linear_velocity)
		var distance_to_camera: float = global_transform.origin.distance_to(get_viewport().get_camera_3d().global_transform.origin)
		audio_stream_player_3d.volume_db = clamp(base_volume + relative_velocity.length() * sound_velocity_factor - distance_to_camera * sound_distance_factor, 0.0, max_volume)
		audio_stream_player_3d.play()
