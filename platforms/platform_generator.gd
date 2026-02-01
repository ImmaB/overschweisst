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
@export var spawn_check_mask: int = 2

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
	end_platform_instance.global_position = global_position + Vector3(0, 0, -5)
	get_tree().current_scene.add_child(end_platform_instance)

func _spawnPlatform():
	var max_tries := 10
	var tries := 0
	var spawned := false
	while tries < max_tries:
		tries += 1
		var spawn_pos := random_point(vol)
		var forq := random_force(maxForce, minForce)
		var torq := random_torque(maxTorque)
		var spawnee = random_spawnee(spawnees)
		if is_instance_valid(spawnee) and _is_spawn_position_free(spawn_pos, spawnee):
			var instancee = spawnee.instantiate()
			instancee.constant_force = forq
			instancee.angular_velocity = torq
			instancee.global_position = spawn_pos
			get_tree().current_scene.add_child(instancee)
			spawned = true
			break
	if not spawned:
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
	var instancee = spawnee.instantiate()
	instancee.global_position = spawn_pos

	var shapes := _collect_collision_shapes(instancee)
	if shapes.is_empty():
		instancee.queue_free()
		return true

	var has_aabb := false
	var combined_aabb := AABB()
	for shape_node in shapes:
		if shape_node.shape == null:
			continue
		var world_transform = instancee.global_transform * shape_node.transform
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

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = query_shape
	params.transform = Transform3D(Basis.IDENTITY, combined_aabb.position + combined_aabb.size * 0.5)
	params.exclude = [get_rid()]
	params.collision_mask = spawn_check_mask
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var space_state := get_world_3d().direct_space_state
	var hits := space_state.intersect_shape(params, 1)

	instancee.queue_free()
	return hits.is_empty()


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


func create_sensor_from_collision(original_collision: CollisionShape3D) -> ShapeCast3D:
	var sensor = ShapeCast3D.new()
	
	# 1. Copy the actual geometry (Box, Sphere, etc.)
	sensor.shape = original_collision.shape
	
	# 2. Match the scale and rotation
	sensor.basis = original_collision.basis
	
	# 3. CRITICAL: Set a tiny target_position so it actually "casts"
	# If this is (0,0,0), the physics engine often ignores the check.
	sensor.target_position = Vector3(0, 0.01, 0)
	
	# 4. Set the Collision Mask
	# This ensures the sensor looks for the right things (e.g., Layer 1 for walls)
	sensor.collision_mask = 1 
	
	# 5. Enable it
	sensor.enabled = true
	
	return sensor
