class_name PlayerManager
extends Node

const PLAYER_CHARACTER := preload("res://player/player_character.tscn")

@export var _first_player: PlayerCharacter

var _players: Dictionary[int, PlayerController] = {}


func _input(event: InputEvent) -> void:
	var device_id := event.get_device()
	if _players.has(device_id):
		_players.get(device_id).input(event)
	else:
		if _players.size() == 0:
			_players.set(device_id, _first_player.controller)
			_first_player.device_id = device_id
			_first_player.controller.input(event)
		else:
			var player_character := _spawn_player()
			_players.set(device_id, player_character.controller)
			player_character.device_id = device_id
			player_character.controller.input(event)

func _spawn_player() -> PlayerCharacter:
	var player_character := PLAYER_CHARACTER.instantiate() as PlayerCharacter
	player_character.global_position = _first_player.global_position + Vector3(1, 0, 0)
	add_child(player_character)
	return player_character
