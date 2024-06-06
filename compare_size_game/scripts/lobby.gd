extends Node3D

@onready var cards = [$Card, $Card2]

var suits = ["club", "diamond", "heart", "spade"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]

func _ready():
	for card in cards:
		randomize()
		card.get_node("AnimationPlayer").play("hover")
		var mesh_instance = card.get_node("MeshInstance3D")
		var random_suit = suits[randi() % suits.size()]
		var random_rank = ranks[randi() % ranks.size()]
		var material_path = "res://materials/card_3d/%s-%s.tres" % [random_suit, random_rank]
		var new_material = load(material_path)
		if new_material != null:
			print("Using %s for card %s" % [material_path, card])
			mesh_instance.mesh.surface_set_material(0, new_material)
		else:
			print("Failed to load material: ", material_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_singleplayer_game_pressed():
	get_tree().change_scene_to_file("res://compare_size_game/scenes/main.tscn")
