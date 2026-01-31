class_name PlayerCamera
extends Node3D

@export var _max_speed: float = 5.0

var _targets: Array[PlayerCharacter]

func set_targets(targets: Array[PlayerCharacter]) -> void:
    _targets = targets

func _process(delta):
    if _targets.size() == 0:
        return
    var position_sum: Vector3 = Vector3.ZERO
    for target in _targets:
        position_sum += target.global_transform.origin
    var average_position: Vector3 = position_sum / _targets.size()
    var to_target: Vector3 = average_position - global_transform.origin
    var distance: float = to_target.length()
    if distance < 0.01:
        return
    var direction: Vector3 = to_target.normalized()
    var move_distance: float = min(distance, _max_speed * delta)
    global_transform.origin += direction * move_distance