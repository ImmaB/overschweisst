class_name WeldSpot
extends Node3D

@onready var _pin_joint_3d: PinJoint3D = $PinJoint3D

func weld_bodies(body_a: Node3D, body_b: Node3D) -> void:
    _pin_joint_3d.node_a = body_a.get_path()
    _pin_joint_3d.node_b = body_b.get_path()