extends RigidBody3D

const WIN_SCREEN := preload("res://core/win_screen.tscn")

var _won := false

func _ready():
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node):
    if _won or not body is PlayerCharacter:
        return
    _won = true
    await get_tree().create_timer(3.0).timeout
    var win_screen: Control = WIN_SCREEN.instantiate()
    get_tree().current_scene.add_child(win_screen)
