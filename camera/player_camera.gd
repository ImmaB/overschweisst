class_name PlayerCamera
extends Node3D

@export var _max_speed: float = 5.0

var _target: Node3D

func set_target(target: Node3D) -> void:
    _target = target

func _process(delta):
    if _target == null:
        return
    var to_target: Vector3 = _target.global_transform.origin - global_transform.origin
    var distance: float = to_target.length()
    if distance < 0.01:
        return
    var direction: Vector3 = to_target.normalized()
    var move_distance: float = min(distance, _max_speed * delta)
    global_transform.origin += direction * move_distance