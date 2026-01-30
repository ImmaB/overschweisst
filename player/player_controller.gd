class_name PlayerController
extends Node

@export var controlled_player: PlayerCharacter

signal start_welding()
signal stop_welding()

func _input(event):
	if not controlled_player:
		return
	
	_handle_movement_input()

	if Input.is_action_just_pressed("Weld"):
		start_welding.emit()
		pass
	if Input.is_action_just_released("Weld"):
		stop_welding.emit()
		pass
	
	

func _handle_movement_input():
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if move_input.length() > 0:
		var camera = get_viewport().get_camera_3d()
		if not camera:
			return
		var camera_y_rotation = camera.global_transform.basis.get_euler().y
		var movement := move_input.rotated(-camera_y_rotation)
		controlled_player.set_movement(movement)
	else:
		controlled_player.velocity = Vector3.ZERO
