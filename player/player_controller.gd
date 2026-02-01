class_name PlayerController
extends Node

@export var controlled_player: PlayerCharacter

var _move_left := 0.0
var _move_right := 0.0
var _move_forward := 0.0
var _move_backward := 0.0

func input(event: InputEvent) -> void:
	if controlled_player == null:
		print("No controlled player assigned.")
		return
		
	_handle_movement_input(event)

	
	if event.is_action_pressed("weld"):
		controlled_player.start_welding()
	if event.is_action_pressed("toggle_vision_cone"):
		controlled_player.toggle_vision_cone()
	if event.is_action_released("weld"):
		controlled_player.stop_welding()
	
	var key_event := event as InputEventKey
	if key_event and key_event.pressed and key_event.keycode == Key.KEY_ESCAPE:
		get_tree().quit()

func _handle_movement_input(event: InputEvent = null) -> void:
	
	var move_input := _get_movement(event)
	if move_input.length_squared() > 1.0:
		move_input = move_input.normalized()
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

func _get_movement(event: InputEvent) -> Vector2:
	# Check if this is a joypad motion event
	var joypad_event := event as InputEventJoypadMotion
	if joypad_event != null:
		var device_id := joypad_event.device
		var strength := joypad_event.axis_value
		
		# Map axis to actions based on your input map
		if joypad_event.axis == JOY_AXIS_LEFT_X:
			if strength < 0:
				_move_left = abs(strength)
				_move_right = 0.0
			else:
				_move_right = strength
				_move_left = 0.0
		elif joypad_event.axis == JOY_AXIS_LEFT_Y:
			if strength < 0:
				_move_forward = abs(strength)
				_move_backward = 0.0
			else:
				_move_backward = strength
				_move_forward = 0.0
	
	# Also handle keyboard input
	var key_event := event as InputEventKey
	if key_event != null:
		if event.is_action("move_left"):
			_move_left = 1.0 if event.is_pressed() else 0.0
		elif event.is_action("move_right"):
			_move_right = 1.0 if event.is_pressed() else 0.0
		elif event.is_action("move_forward"):
			_move_forward = 1.0 if event.is_pressed() else 0.0
		elif event.is_action("move_backward"):
			_move_backward = 1.0 if event.is_pressed() else 0.0

	return Vector2(
		_move_right - _move_left,
		_move_backward - _move_forward
	)