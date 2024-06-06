extends Node3D

@onready var card_animations = [$Card/AnimationPlayer, $Card2/AnimationPlayer]

# Called when the node enters the scene tree for the first time.
func _ready():
	for a in card_animations:
		a.play("hover")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_singleplayer_game_pressed():
	get_tree().change_scene_to_file("res://compare_size_game/scenes/main.tscn")
