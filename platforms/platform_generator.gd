class_name PlatformGenerator
extends Area3D

const END_PLATFORM := preload("res://platforms/end_platform/end_platform.tscn")

@onready var vol = $CollisionShape3D
@export var distance_to_player: float = 13.0
@export var spawnees: Array[PackedScene] =  []

#@export var spawnee: PackedScene
@export var maxForce: Vector3
@export var minForce: Vector3
@export var maxTorque: Vector3
@export var spawn_check_mask: int = 8
@export var spawn_aabb_padding: float = 0.05

@onready var timer: Timer = $Timer


func _ready() -> void:
	GameManager.platform_generator = self


func random_point(vol: CollisionShape3D) -> Vector3:
	var shape = vol.shape as BoxShape3D
	var relHalfSize = shape.size / 2
	var randPos = Vector3(
		randf_range(-relHalfSize.x, relHalfSize.x),
		randf_range(0, 0),
		randf_range(-relHalfSize.z, relHalfSize.z))
	return vol.global_transform * randPos


func random_torque(maxTorq: Vector3) -> Vector3:
	var randTorq = Vector3(
		randf_range(0, 0),
		randf_range(-maxTorq.y, maxTorq.y),
		randf_range(0, 0))
	return randTorq
	
func random_force(maxForce: Vector3, minForce: Vector3) -> Vector3:
	var randForce = Vector3(
		randf_range(minForce.x, maxForce.x),
		randf_range(0, 0),
		randf_range(minForce.z, maxForce.z))
	return randForce
	
func random_spawnee(spawnees: Array[PackedScene]) -> PackedScene:
	var current_spawnee = spawnees.pick_random()
	return current_spawnee

func spawn_end_platform():
	print("Spawning End Platform")
	timer.stop()
	var end_platform_instance = END_PLATFORM.instantiate()
	end_platform_instance.global_position = global_position + Vector3(0, 0, -3)
	get_tree().current_scene.add_child(end_platform_instance)

func _spawnPlatform():
	var max_tries := 10
	var tries := 0
	while tries < max_tries:
		tries += 1
		var spawn_pos := random_point(vol)
		var forq := random_force(maxForce, minForce)
		var torq := random_torque(maxTorque)
		var spawnee = random_spawnee(spawnees)
		if not _is_spawn_position_free(spawn_pos, spawnee):
			continue
		var instancee: RigidBody3D = spawnee.instantiate()
		instancee.constant_force = forq
		instancee.angular_velocity = torq
		instancee.global_position = spawn_pos
		get_tree().current_scene.add_child(instancee)
		return
	print("Failed to spawn platform after %d tries" % tries)


func _on_timer_timeout() -> void:
	_adjust_position_to_players()
	_spawnPlatform()


func _adjust_position_to_players() -> void:
	var position_sum := Vector3.ZERO
	for player in GameManager.player_characters:
		position_sum += player.global_transform.origin
	var average_position := position_sum / GameManager.player_characters.size()
	position.x = average_position.x
	position.z = average_position.z - distance_to_player


func _is_spawn_position_free(spawn_pos: Vector3, spawnee: PackedScene) -> bool:
	var instancee: RigidBody3D = spawnee.instantiate()
	instancee.global_position = spawn_pos
	var base_transform := Transform3D(instancee.transform.basis, spawn_pos)

	var shapes := _collect_collision_shapes(instancee)
	if shapes.is_empty():
		instancee.queue_free()
		return true

	var has_aabb := false
	var combined_aabb := AABB()
	for shape_node in shapes:
		if shape_node.shape == null:
			continue
		var world_transform = _get_world_transform_from_instance(base_transform, instancee, shape_node)
		var shape_aabb = _aabb_transformed(_shape_get_aabb(shape_node.shape), world_transform)
		if not has_aabb:
			combined_aabb = shape_aabb
			has_aabb = true
		else:
			combined_aabb = combined_aabb.merge(shape_aabb)

	if not has_aabb:
		instancee.queue_free()
		return true

	var query_shape := BoxShape3D.new()
	query_shape.size = combined_aabb.size

	var platforms := get_tree().get_nodes_in_group("weldable")
	for platform in platforms:
		if not (platform is Node3D):
			continue
		var platform_shapes := _collect_collision_shapes(platform)
		for shape_node in platform_shapes:
			if shape_node.shape == null:
				continue
			var world_transform := (shape_node as Node3D).global_transform
			var platform_aabb := _aabb_transformed(_shape_get_aabb(shape_node.shape), world_transform)
			var combined_test := _aabb_shrink_safe(combined_aabb, spawn_aabb_padding)
			var platform_test := _aabb_shrink_safe(platform_aabb, spawn_aabb_padding)
			if combined_test.intersects(platform_test):
				instancee.queue_free()
				return false

	instancee.queue_free()
	return true


func _collect_collision_shapes(root: Node) -> Array[CollisionShape3D]:
	var shapes: Array[CollisionShape3D] = []
	if root is CollisionShape3D:
		shapes.append(root)
	for child in root.get_children():
		if child is CollisionShape3D:
			shapes.append(child)
		if child.get_child_count() > 0:
			shapes.append_array(_collect_collision_shapes(child))
	return shapes


func _shape_get_aabb(shape: Shape3D) -> AABB:
	if shape is ConcavePolygonShape3D:
		var debug_mesh := shape.get_debug_mesh()
		if debug_mesh:
			return debug_mesh.get_aabb()
		var faces := (shape as ConcavePolygonShape3D).get_faces()
		if faces.is_empty():
			return AABB()
		var aabb := AABB(faces[0], Vector3.ZERO)
		for i in range(1, faces.size()):
			aabb = aabb.expand(faces[i])
		return aabb
	if shape.has_method("get_aabb"):
		return shape.get_aabb()
	var debug_mesh := shape.get_debug_mesh()
	if debug_mesh:
		return debug_mesh.get_aabb()
	return AABB()


func _aabb_transformed(aabb: AABB, xform: Transform3D) -> AABB:
	if aabb.size == Vector3.ZERO:
		return aabb
	var p0 = xform * aabb.position
	var p1 = xform * (aabb.position + Vector3(aabb.size.x, 0, 0))
	var p2 = xform * (aabb.position + Vector3(0, aabb.size.y, 0))
	var p3 = xform * (aabb.position + Vector3(0, 0, aabb.size.z))
	var p4 = xform * (aabb.position + Vector3(aabb.size.x, aabb.size.y, 0))
	var p5 = xform * (aabb.position + Vector3(aabb.size.x, 0, aabb.size.z))
	var p6 = xform * (aabb.position + Vector3(0, aabb.size.y, aabb.size.z))
	var p7 = xform * (aabb.position + aabb.size)
	var out := AABB(p0, Vector3.ZERO)
	out = out.expand(p1)
	out = out.expand(p2)
	out = out.expand(p3)
	out = out.expand(p4)
	out = out.expand(p5)
	out = out.expand(p6)
	out = out.expand(p7)
	return out


func _aabb_shrink_safe(aabb: AABB, padding: float) -> AABB:
	if padding <= 0.0:
		return aabb
	var shrunk := aabb.grow(-padding)
	if shrunk.size.x <= 0.0 or shrunk.size.y <= 0.0 or shrunk.size.z <= 0.0:
		return aabb
	return shrunk


func _get_world_transform_from_instance(base_transform: Transform3D, instancee: Node3D, shape_node: Node3D) -> Transform3D:
	var xform := Transform3D.IDENTITY
	var current: Node = shape_node
	while current != null and current != instancee:
		if current is Node3D:
			xform = (current as Node3D).transform * xform
		current = current.get_parent()
	return base_transform * xform
