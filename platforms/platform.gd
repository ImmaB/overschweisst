class_name Platform
extends RigidBody3D

@export var lifetime: float = 5.0
@export var _mass: float = 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var _timer: Timer = $Timer


func _ready():
    _timer.wait_time = lifetime
    _timer.start()
    _timer.timeout.connect(_start_melting)
    mass = _mass

func _start_melting() -> void:
    animation_player.play("melt")