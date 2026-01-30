class_name PlayerCharacter
extends CharacterBody3D

@export var movement_speed: float = 2.0
@export var welding_interval: float = 0.2
@export var aerial_control_factor: float = 0.5
@export var acceleration: float = 10.0

var _gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var _move_direction: Vector2

func set_movement(direction: Vector2) -> void:
    _move_direction = direction.normalized() if direction.length_squared() > 1.0 else direction

func stop_movement() -> void:
    _move_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
    var on_floor := is_on_floor()
    var movement := _calc_movement(_move_direction, on_floor)
    var velocity_x := move_toward(velocity.x, movement.x, acceleration * delta)
    var velocity_z := move_toward(velocity.z, movement.y, acceleration * delta)
    velocity = Vector3(velocity_x, velocity.y, velocity_z) if on_floor else velocity + _gravity * delta
    move_and_slide()

func _calc_movement(move_direction: Vector2, on_floor: bool) -> Vector2:
    if move_direction.length_squared() < 0.01: return Vector2.ZERO
    var movement = move_direction * movement_speed
    if not on_floor:
        movement *= aerial_control_factor
    return movement
