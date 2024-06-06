class_name SinglePlayerGameManager
extends Node

var local: PlayZone
var remote: PlayZone

var local_score = 0
var remote_score = 0

var local_deck_cards: Array[Dictionary] = []
var remote_deck_cards: Array[Dictionary] = []

var local_hand_cards: Array[Dictionary] = []
var remote_hand_cards: Array[Dictionary] = []

var local_table_card = null
var remote_table_card = null

func initialize(local_play_zone: PlayZone, remote_play_zone: PlayZone):
	local = local_play_zone
	remote = remote_play_zone

func run():
	var func_cards_map = func(card_data):
		return {"rank": Cards.Rank[card_data.rank], "suit": Cards.Suit[card_data.suit]}
		
	var func_cards_filter = func(card_data):
		return card_data["rank"] != Cards.Rank.UNKNOWN && card_data["suit"] != Cards.Suit.UNKNOWN
		
	var cards = Cards.generate_all_cards().values().map(func_cards_map).filter(func_cards_filter)
	cards.shuffle()
	
	var deck_size = cards.size() / 2
	for _i in deck_size:
		local_deck_cards.push_front(cards[0])
		cards.remove_at(0)
	for _i in deck_size:
		remote_deck_cards.push_front(cards[0])
		cards.remove_at(0)
		
	var initial_cards:Array[Dictionary] = []
	for _i in range(3):
		initial_cards.push_back(_draw_card(local_deck_cards, local_hand_cards))
	for _i in range(3):
		_draw_card(remote_deck_cards, remote_hand_cards)
	
	local.set_initial_hand_cards(initial_cards)
	local.initialize(deck_size, 3)
	await remote.initialize(deck_size, 3)
	
	var hud = get_parent().find_child("HUD")
	hud.find_child("ScoreLabel").visible = true
	
func _draw_card(deck: Array[Dictionary], hand: Array[Dictionary]) -> Dictionary:
	var draw = deck.pop_front()
	hand.push_back(draw)
	return draw
	
func draw_card_for_local():
	if local_deck_cards.is_empty():
		return
	local.draw_card(_draw_card(local_deck_cards, local_hand_cards))
	
func draw_card_for_remote():
	if remote_deck_cards.is_empty():
		return
	var draw = _draw_card(remote_deck_cards, remote_hand_cards)
	remote.draw_card({"rank": Cards.Rank.UNKNOWN, "suit": Cards.Suit.UNKNOWN})
	
func on_player_play_card(card):
	local_hand_cards.erase(card)
	local_table_card = card
	
func play_card_for_remote():
	var play = remote_hand_cards.pick_random()
	remote_hand_cards.erase(play)
	remote.play_card(play)
	remote_table_card = play
	
func settle_round():
	if local_table_card == null or remote_table_card == null:
		push_error("One of player not ready yet, failed to settle round.")
		return
		
	var hud = get_parent().find_child("HUD");
	var label = Label.new()
	label.global_position = hud.find_child("WinFailIndicatorLocationMarker").global_position
	label.add_theme_font_size_override("font_size", 20)
		
	if local_table_card["rank"] > remote_table_card["rank"]:
		local_score += 1;
		label.text = "胜"
	elif local_table_card["rank"] < remote_table_card["rank"]:
		remote_score += 1;
		label.text = "负"
	else:
		label.text = "平局"
	
	hud.find_child("ScoreLabel").text = "分数：" + str(local_score)
	
	hud.add_child(label)
	await get_tree().create_timer(2.0).timeout
	label.queue_free()
	
	local.discard_card()
	local_table_card = null
	remote.discard_card()
	remote_table_card = null
	
	if local_hand_cards.is_empty() or remote_hand_cards.is_empty():
		settle_game()
	
func settle_game():
	var hud = get_parent().find_child("HUD");
	hud.visible = false
	
	var gui = get_parent().find_child("GUI")
	
	var win_fail_label = gui.find_child("WinFailLabel")
	if local_score > remote_score:
		win_fail_label.text = "👑胜利👑"
	elif local_score < remote_score:
		win_fail_label.text = "失败..."
	else: 
		win_fail_label.text = "平局"
		
	var local_user_score = gui.find_child("LocalUserScore")
	local_user_score.text = str(local_score)
	var remote_user_score = gui.find_child("RemoteUserScore")
	remote_user_score.text = str(remote_score)
		
	gui.visible = true
