extends Area3D

@onready var vol = $CollisionShape3D
@export var spawnees: Array[PackedScene] =  []
#@export var spawnee: PackedScene
@export var maxForce: Vector3
@export var minForce: Vector3
@export var maxTorque: Vector3

var _player_characters: Array[PlayerCharacter]

func _ready() -> void:
	_player_characters = GameManager.get_player_characters()


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

func _spawnPlatform():
	var maxTries := 0
	while maxTries < 10:
		maxTries += 1
		var spawnPos := random_point(vol)
		var forq := random_force(maxForce, minForce)
		var torq := random_torque(maxTorque)
		var spawnee = random_spawnee(spawnees)
		if is_instance_valid(spawnee):
			var instancee = spawnee.instantiate()
			var instCollisionShape = instancee.get_node("CollisionShape3D")
			var instShapeCast = create_sensor_from_collision(instCollisionShape)
			add_child(instShapeCast) 
			instShapeCast.force_shapecast_update()
			
			if instShapeCast.is_colliding():
				instancee.queue_free()
				instShapeCast.queue_free()
				continue
			else:
				instancee.constant_force = forq
				instancee.angular_velocity = torq
				get_tree().root.add_child(instancee)
				instancee.global_position = spawnPos
				break


func _on_timer_timeout() -> void:
	_adjust_position_to_players()
	_spawnPlatform()


func _adjust_position_to_players() -> void:
	var x_position_sum = 0.0
	for player in _player_characters:
		x_position_sum += player.global_transform.origin.x
	var average_x_position = x_position_sum / _player_characters.size()
	position.x = average_x_position


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
