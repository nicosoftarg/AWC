extends Node

func stop_game(self_player, Match):
	match self_player.current_player_state:
		self_player.PlayerState.GO_TO_CELEBRATION:
			if Match.goal_scorer != self_player:
				self_player.target = Match.goal_scorer.global_position
				self_player.move = true
				self_player.can_move = true
				self_player.look_at(self_player.target)
				self_player.get_node("AnimatedSprite2D").play("goal_no_scorer")
		_:
			self_player.target = self_player.global_position
			self_player.at_target = true
			self_player.get_node("AnimatedSprite2D").play("idle")	
	if self_player.distance_to_target_general < 1:
		self_player.at_target = true
	else:
		self_player.at_target = false	
	if self_player.at_target:
		self_player.move = false
		self_player.get_node("AnimatedSprite2D").play("idle")
	else:
		self_player.move = true
		
		#self_player.move_animations()
