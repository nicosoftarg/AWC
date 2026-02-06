extends Node

@onready var update_in_game = $UpdateInGame
@onready var update_positioning = $UpdatePositioning
@onready var update_restarting = $UpdateRestarting
@onready var update_stop_game = $UpdateStopGame


func update_behavior_tree(self_player, match_root, ball):
	match match_root.current_match_state:
		match_root.MatchState.IN_GAME:
			update_in_game.in_game(self_player, match_root, ball)
		match_root.MatchState.POSITIONING:
			update_positioning.positioning(self_player, match_root)
		match_root.MatchState.RESTARTING:
			update_restarting.restarting(self_player, match_root, ball)
		match_root.MatchState.STOP_GAME:
			update_stop_game.stop_game(self_player, match_root)
