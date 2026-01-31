class_name Floor
extends Node3D

@onready var _death_zone: Area3D = $DeathZone

func _ready() -> void:
    _death_zone.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
    var player_character: PlayerCharacter = body as PlayerCharacter
    if player_character:
        player_character.die()