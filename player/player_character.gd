class_name PlayerCharacter
extends CharacterBody3D

const VISION_CONE := preload("res://player/vision_cone.tscn")

@export var movement_speed: float = 2.0
@export var turn_speed: float = 5.0
@export var aerial_control_factor: float = 0.5
@export var acceleration: float = 10.0
@export var turn_acceleration: float = 10.0

@onready var _welder: Welder = $Welder
@onready var _vision_cone_position: Node3D = $VisionConePosition

var _gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var _move_direction: Vector2
var _look_rotation: float
var _fall_direction: float = 45

func _ready():
    GameManager.register_player(self)
    var vision_cone := VISION_CONE.instantiate()
    _vision_cone_position.add_child(vision_cone)

func die() -> void:
    GameManager.player_died(self)

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
    if not on_floor: # look up/down while in air
        rotation.x = lerp_angle(rotation.x, _fall_direction, turn_acceleration * delta)
    elif rotation.x != 0.0:
        if randf() < 0.5:
            _fall_direction *= -1
        rotation.x = lerp_angle(rotation.x, 0.0, turn_acceleration * delta)
    move_and_slide()

func _calc_movement(move_direction: Vector2, on_floor: bool) -> Vector2:
    if move_direction.length_squared() < 0.01: return Vector2.ZERO
    var movement = move_direction * movement_speed
    if not on_floor:
        movement *= aerial_control_factor
    return movement
