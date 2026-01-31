class_name PlayerController
extends Node

@export var controlled_player: PlayerCharacter

func _input(event):
	if controlled_player == null:
		print("No controlled player assigned.")
		return
		
	_handle_movement_input()

	if Input.is_action_just_pressed("weld"):
		controlled_player.start_welding()
	if Input.is_action_just_released("weld"):
		controlled_player.stop_welding()

func _handle_movement_input():
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if move_input.length_squared() > 0:
		var camera = get_viewport().get_camera_3d()
		if not camera:
			return
		var camera_y_rotation = camera.global_transform.basis.get_euler().y
		var movement := move_input.rotated(-camera_y_rotation)
		controlled_player.set_movement(movement)
		controlled_player.set_look_direction(movement)
	else:
		controlled_player.stop_movement()
		
