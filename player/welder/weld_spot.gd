class_name WeldSpot
extends Node3D

const WELD_SPOT_SCENE: PackedScene = preload("res://player/welder/weld_spot.tscn")

@onready var _pin_joint_3d: PinJoint3D = $PinJoint3D

static func create(parent: Node3D, _global_position: Vector3) -> WeldSpot:
	var weld_spot: WeldSpot = WELD_SPOT_SCENE.instantiate()
	parent.add_child(weld_spot)
	weld_spot.position = parent.to_local(_global_position)
	weld_spot._pin_joint_3d.node_a = parent.get_path()
	return weld_spot

func weld_to(body: Node3D) -> void:
	_pin_joint_3d.node_b = body.get_path()