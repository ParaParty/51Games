class_name PlayZone
extends DragController

@export var playable: bool = false

var cards = Cards.new()

@onready var hand: CardCollection3D = $HandCards
@onready var discard: CardCollection3D = $DiscardCards
@onready var deck: CardCollection3D = $DeckCards
@onready var table: CardCollection3D = $TableCards

var initial_hand_cards = [
	{"rank": Cards.Rank.UNKNOWN, "suit": Cards.Suit.UNKNOWN},
	{"rank": Cards.Rank.UNKNOWN, "suit": Cards.Suit.UNKNOWN},
	{"rank": Cards.Rank.UNKNOWN, "suit": Cards.Suit.UNKNOWN}
]

var max_hand_size = 3

# emit when need to acquire game manager to draw a new card
signal acquire_draw_card
# emit when player play card
signal player_play_card(card: Dictionary)

func _ready():
	super._ready()
	
	# Interact with non-playable play zone is not allowed.
	if not playable:
		for card_collection in find_children("*", "CardCollection3D", false) as Array[CardCollection3D]:
			card_collection.reorderable = false
			card_collection.insertable = false
			card_collection.removable = false
		
func set_initial_hand_cards(cards: Array[Dictionary]):
	if not playable:
		push_error("There's no need to initalize initial hand cards for remote player.")
		return
	
	initial_hand_cards = cards
			
func initialize(deck_size: int, max_hand_size: int):
	var func_check_initialzed = func(card):
		card["rank"] == Cards.Rank.UNKNOWN && card["suit"] == Cards.Suit.UNKNOWN
		
	if playable and initial_hand_cards.all(func_check_initialzed):
		push_error("There's no need to initalize initial hand cards for remote player.")
		return
	
	await _initialize_deck_cards(deck_size)
	await _initialize_hand_cards(max_hand_size)

func _instantiate_face_card(rank: Cards.Rank, suit: Cards.Suit) -> FaceCard3D:
	var scene = load("res://compare_size_game/scenes/face_card_3d.tscn")
	var face_card_3d: FaceCard3D = scene.instantiate()
	var card_data: Dictionary = cards.get_card_data(rank, suit)
	face_card_3d.rank = Cards.Rank[card_data["rank"]]
	face_card_3d.suit = Cards.Suit[card_data["suit"]]
	face_card_3d.front_material_path = card_data["front_material_path"]
	face_card_3d.back_material_path = card_data["back_material_path"]
	
	return face_card_3d

func _initialize_deck_cards(deck_size: int):
	for _i in range(deck_size):
		var card = _instantiate_face_card(Cards.Rank.UNKNOWN, Cards.Suit.UNKNOWN)
		await get_tree().create_timer(3.0 / deck_size).timeout
		deck.add_card(card)
		card.global_position = $DrawCardPositionMarker.global_position
		
func _initialize_hand_cards(p_max_hand_size: int):
	max_hand_size = p_max_hand_size
	for card_data in initial_hand_cards:
		await draw_card(card_data)

func draw_card(card_data: Dictionary):
	if hand.cards.size() == max_hand_size:
		push_error("Can not draw card when hand cards more than" + str(max_hand_size))
		return
	
	var card = _instantiate_face_card(card_data["rank"], card_data["suit"]) if playable else _instantiate_face_card(Cards.Rank.UNKNOWN, Cards.Suit.UNKNOWN)
	await get_tree().create_timer(0.2).timeout
	hand.add_card(card)
	deck.remove_card(0)
	card.global_position = deck.global_position
	
	if playable:
		card.card_3d_mouse_down.connect(play_card.bind({"rank": card.rank, "suit": card.suit}))
	
func play_card(card_data: Dictionary):
	if not table.cards.is_empty():
		return
	
	var card_index_filter = func(card):
		return card.rank == card_data["rank"] && card.suit == card_data["suit"]
		
	var card = hand.cards.filter(card_index_filter).front() if playable else hand.cards.pick_random()
	var card_index = hand.cards.find(card)
	var card_global_position = hand.cards[card_index].global_position
	var c = hand.remove_card(card_index)
	
	if not playable:
		c.front_material_path = cards.get_card_data(card_data["rank"], card_data["suit"])["front_material_path"]
	
	table.add_card(c)
	c.remove_hovered()
	c.global_position = card_global_position
	
	if playable:
		player_play_card.emit({"rank": c.rank, "suit": c.suit})
	
	await get_tree().create_timer(0.5).timeout
	acquire_draw_card.emit()
	
func discard_card():
	var card_global_position = table.cards[0].global_position
	var c = table.remove_card(0)
	
	discard.add_card(c)
	c.remove_hovered()
	c.global_position = card_global_position
	
