class_name FaceCard3D
extends Card3D


@export var rank: Cards.Rank = Cards.Rank.UNKNOWN
@export var suit: Cards.Suit = Cards.Suit.UNKNOWN
@export var front_material_path: String:
	set(path):
		if path:
			var material = load(path)
			
			if material:
				$CardMesh/CardFrontMesh.set_surface_override_material(0, material)
		
@export var back_material_path: String:
	set(path):
		if path:
			var material = load(path)
			
			if material:
				$CardMesh/CardBackMesh.set_surface_override_material(0, material)
