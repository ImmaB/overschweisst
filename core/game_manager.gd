extends Node

const GAME_OVER_SCREEN := preload("res://core/game_over_screen.tscn")

var player_characters: Array[PlayerCharacter] = []
var platform_generator: PlatformGenerator


func register_player(player: PlayerCharacter) -> void:
	player_characters.append(player)


func player_died(player: PlayerCharacter) -> void:
	player_characters.erase(player)
	if player_characters.size() == 0:
		_game_over()


func _game_over() -> void:
	var game_over_screen = GAME_OVER_SCREEN.instantiate()
	get_tree().current_scene.add_child(game_over_screen)
