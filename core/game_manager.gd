extends Node

const GAME_OVER_SCREEN := preload("res://core/game_over_screen.tscn")

var _player_characters: Array[PlayerCharacter] = []

func get_player_characters() -> Array[PlayerCharacter]:
    return _player_characters

func register_player(player: PlayerCharacter) -> void:
    _player_characters.append(player)

func player_died(player: PlayerCharacter) -> void:
    _player_characters.erase(player)
    if _player_characters.size() == 0:
        _game_over()
    
func _game_over() -> void:
    var game_over_screen = GAME_OVER_SCREEN.instantiate()
    get_tree().current_scene.add_child(game_over_screen)