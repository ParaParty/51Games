class_name Cards
extends Resource

enum Rank {
	UNKNOWN = 0,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	JACK = 11,
	QUEEN = 12,
	KING = 13,
	ACE = 14
}

enum Suit {
	UNKNOWN,
	HEART,
	DIAMOND,
	CLUB,
	SPADE
}

static var materials_base_path: String = "res://materials/card_3d/"

var data: Dictionary = generate_all_cards()

func get_card_data(rank: Rank, suit: Suit):
	var card_id = get_card_id(rank, suit)
	
	if data.has(card_id):
		return data[card_id]
	
	return null
	
static func get_card_id(rank: Rank, suit: Suit) -> String:
	return str(rank) + " of " + str(suit)


static func generate_all_cards() -> Dictionary:
	var _data = {}
	
	for suit in Suit:
		for rank in Rank:
			var back_material = materials_base_path + "card-back.tres"
			var front_material = materials_base_path + str(suit).to_lower() + "-" + str(Rank[rank]) + ".tres" if Rank[rank] != Rank.UNKNOWN && Suit[suit] != Suit.UNKNOWN else back_material
			var card_data = {
				"rank": rank,
				"suit": suit,
				"front_material_path": front_material,
				"back_material_path": back_material
			}
			var card_id = get_card_id(Rank[rank], Suit[suit])
			_data[card_id] = card_data
			
	return _data 
