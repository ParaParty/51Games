extends Node3D

@onready var cards = [$Card, $Card2]

var suits = Cards.Suit.keys()
var ranks = Cards.Rank.values()

func _ready():
	for card in cards:
		card.get_node("AnimationPlayer").play("hover")
		var mesh_instance = card.get_node("MeshInstance3D")
		var random_suit = suits[randi() % suits.size()].to_lower()
		var random_rank = ranks[randi() % ranks.size()]
		var material_path = "res://materials/card_3d/%s-%s.tres" % [random_suit, random_rank]
		var new_material = load(material_path)
		if new_material != null:
			mesh_instance.mesh.surface_set_material(0, new_material)
		else:
			push_error("Failed to load material: ", material_path)


func _on_play_singleplayer_game_pressed():
	get_tree().change_scene_to_file("res://compare_size_game/scenes/main.tscn")
