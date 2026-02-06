extends Node

func positioning(self_player, Match):
	if Match.current_game_mode == Match.GameMode.CPU_VS_CPU or \
		Match.current_team_posesion == 1:
		if self_player.current_player_state == self_player.PlayerState.RESTARTER:
			if self_player.distance_to_target_general < 3:
				self_player.at_target = true
				Match.current_match_state = Match.MatchState.RESTARTING
				Match.match_state_changed.emit()
			else:
				self_player.at_target = false
		else:
			if self_player.distance_to_target_general < 3:
				self_player.at_target = true
			else:
				self_player.at_target = false
		if self_player.at_target:
			self_player.move = false
			self_player.get_node("AnimatedSprite2D").play("idle")
		else:
			self_player.move = true

	else:
		if self_player.current_player_state == self_player.PlayerState.RESTARTER or self_player.current_player_state == self_player.PlayerState.USER_RESTARTING:
			Match.player_controlled = self_player
			if self_player.distance_to_target_general < 3:
				self_player.at_target = true
				Match.current_match_state = Match.MatchState.RESTARTING
				self_player.current_player_state = self_player.PlayerState.USER_RESTARTING
			else:
				self_player.at_target = false
		if self_player.at_target:
			self_player.move = false
			self_player.get_node("AnimatedSprite2D").play("idle")
		else:
			self_player.move = true
	
	if self_player.current_player_state == self_player.PlayerState.GO_TO_CORNER_POSITION or self_player.current_player_state == self_player.PlayerState.GO_TO_POSITION:
		if self_player.distance_to_target_general < 3:
			self_player.at_target = true
		else:
			self_player.at_target = false	
		if self_player.at_target:
			self_player.move = false
			self_player.get_node("AnimatedSprite2D").play("idle")
		else:
			self_player.move = true
			self_player.get_node("AnimatedSprite2D").play("run")
			
	self_player.move_animations()
