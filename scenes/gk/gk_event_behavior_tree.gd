extends Node

@onready var event_in_game: Node = $EventInGame
@onready var event_positioning: Node = $EventPositioning
@onready var event_restarting: Node = $EventRestarting
@onready var event_stop_game: Node = $EventStopGame


func event_behavior_tree(Match, self_gk, ball):
		match_state_machine(Match, self_gk, ball)

func match_state_machine(Match, self_gk, ball):
	match Match.current_match_state:
		Match.MatchState.IN_GAME:
			event_in_game.in_game(Match, self_gk, ball)
		Match.MatchState.STOP_GAME:
			event_stop_game.stop_game(self_gk, Match)
		Match.MatchState.POSITIONING:
			event_positioning.positioning(self_gk)
		Match.MatchState.RESTARTING:
			event_restarting.restarting(self_gk)
