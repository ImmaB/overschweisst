class_name PlayerCharacter
extends CharacterBody3D

@export var movement_speed: float = 2.0
@export var turn_speed: float = 5.0
@export var aerial_control_factor: float = 0.5
@export var acceleration: float = 10.0
@export var turn_acceleration: float = 10.0

@onready var _vision_cone: Node3D = $VisionCone
@onready var _welder: Welder = $Welder

var _gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var _move_direction: Vector2
var _look_rotation: float

func _ready():
    _vision_cone.visible = true

func set_movement(direction: Vector2) -> void:
    _move_direction = direction.normalized() if direction.length_squared() > 1.0 else direction

func set_look_direction(direction: Vector2) -> void:
    if direction.length_squared() < 0.01 or _welder.is_welding: return
    _look_rotation = atan2(direction.x, direction.y) - PI

func stop_movement() -> void:
    _move_direction = Vector2.ZERO

func start_welding() -> void:
    _welder.start_welding()

func stop_welding() -> void:
    _welder.stop_welding()

func _physics_process(delta: float) -> void:
    var on_floor := is_on_floor()
    var movement := _calc_movement(_move_direction, on_floor)
    var velocity_x := move_toward(velocity.x, movement.x, acceleration * delta)
    var velocity_z := move_toward(velocity.z, movement.y, acceleration * delta)
    velocity = Vector3(velocity_x, velocity.y, velocity_z) if on_floor else velocity + _gravity * delta
    rotation.y = lerp_angle(rotation.y, _look_rotation, turn_acceleration * delta)
    move_and_slide()

func _calc_movement(move_direction: Vector2, on_floor: bool) -> Vector2:
    if move_direction.length_squared() < 0.01: return Vector2.ZERO
    var movement = move_direction * movement_speed
    if not on_floor:
        movement *= aerial_control_factor
    return movement
