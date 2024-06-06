extends Node3D

@onready var local = $Table/LocalPlayZone
@onready var remote = $Table/RemotePlayZone
@onready var manager: SinglePlayerGameManager = $SinglePlayerGameManager

func _ready():
	manager.initialize(local, remote)
	start_game()
	

func start_game():
	manager.run()
	
	
func end_game():
	get_tree().change_scene_to_file("res://compare_size_game/scenes/lobby.tscn")
	

func _on_local_play_zone_acquire_draw_card():
	manager.draw_card_for_local()


func _on_local_play_zone_player_play_card(card):
	manager.on_player_play_card(card)
	manager.play_card_for_remote()
	manager.settle_round()


func _on_remote_play_zone_acquire_draw_card():
	manager.draw_card_for_remote()


func _on_back_to_lobby_button_pressed():
	end_game()
