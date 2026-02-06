extends Node

func stop_game(self_gk, Match):
	match self_gk.current_player_state:
		self_gk.PlayerState.SAVING:
			if Match.current_restarting_state == Match.RestartingState.KICK_OFF:
				self_gk.get_node("AnimatedSprite2D").play("save")
				await get_tree().create_timer(1.5).timeout
				self_gk.can_move = true
				self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION
				
	
	
