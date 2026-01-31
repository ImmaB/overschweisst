class_name WeldSpot
extends Node3D

const WELD_SPOT_SCENE: PackedScene = preload("res://player/welder/weld_spot.tscn")

@onready var _pin_joint_3d: PinJoint3D = $PinJoint3D
@onready var _mesh_instance_3d: MeshInstance3D = $MeshInstance3D

static func create(parent: Node3D, _global_position: Vector3, radius: float) -> WeldSpot:
	var weld_spot: WeldSpot = WELD_SPOT_SCENE.instantiate()
	parent.add_child(weld_spot)
	weld_spot.position = parent.to_local(_global_position)
	weld_spot._mesh_instance_3d.mesh.radius = radius
	weld_spot._mesh_instance_3d.mesh.height = radius * 2.0
	return weld_spot

func weld_to(body: Node3D) -> void:
	var parent := get_parent() as Node3D
	_pin_joint_3d.node_a = parent.get_path()
	_pin_joint_3d.node_b = body.get_path()
	_remove_constant_forces(parent)
	_remove_constant_forces(body)

func _remove_constant_forces(body: Node3D) -> void:
	var rigid_body := body as RigidBody3D
	if rigid_body:
		rigid_body.constant_force = Vector3.ZERO
		rigid_body.constant_torque = Vector3.ZERO
