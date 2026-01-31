class_name WeldSpark
extends Node3D

func spark(with_energy: bool = true) -> void:
    var animation_player: AnimationPlayer = $AnimationPlayer
    animation_player.play("spark" if with_energy else "empty")