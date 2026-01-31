class_name Platform
extends RigidBody3D

@export var lifetime: float = 120.0

@onready var _timer: Timer = $Timer
@export var _mass: float = 1.0

func _ready():
    _timer.wait_time = lifetime
    _timer.start()
    mass = _mass