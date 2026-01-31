class_name Platform
extends RigidBody3D

@export var lifetime: float = 45.0

@onready var _timer: Timer = $Timer
@export var _mass: float = 1.0

func _ready():
    _timer.wait_time = lifetime
    _timer.start()
    _timer.timeout.connect(_on_Timer_timeout)
    mass = _mass

func _on_Timer_timeout() -> void:
    queue_free()