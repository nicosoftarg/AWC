extends Node

@onready var update_restarting = get_tree().get_first_node_in_group("update_restarting")

func restarting(self_player, Match, ball):
	self_player.look_at(ball.global_position)
	match Match.current_restarting_state:
		Match.RestartingState.KICK_OFF:
			if Match.current_team_posesion == self_player.own_team:
				if self_player.get_parent().restarter1 == self_player:
					ball.look_at(self_player.get_parent().restarter2.global_position)
					if self_player.own_team == 0:
						self_player.restarter_behaviour_user_team(self_player.get_parent().restarter1)
					else:
						self_player.restarter_behaviour_cpu_team(self_player.get_parent().restarter1)
		Match.RestartingState.GOAL_KICK_0:
			if self_player.own_team == 0:
				self_player.restarter_behaviour_user_team(self_player.get_parent().restarter_goal_kick)
		Match.RestartingState.GOAL_KICK_1:
			if self_player.own_team == 1:
				self_player.restarter_behaviour_cpu_team(self_player.get_parent().restarter_goal_kick)
		Match.RestartingState.CORNER_KICK_L_0:
			if self_player.own_team == 0:
				self_player.restarter_behaviour_user_team(self_player.get_parent().restarter_corner)		
		Match.RestartingState.CORNER_KICK_R_0:
			if self_player.own_team == 0:
				self_player.restarter_behaviour_user_team(self_player.get_parent().restarter_corner)
		Match.RestartingState.CORNER_KICK_L_1:
			if self_player.own_team == 1:
				self_player.restarter_behaviour_cpu_team(self_player.get_parent().restarter_corner)
		Match.RestartingState.CORNER_KICK_R_1:
			if self_player.own_team == 1:
				self_player.restarter_behaviour_cpu_team(self_player.get_parent().restarter_corner)
		Match.RestartingState.THROW_IN_L_0: 
			if self_player.own_team == 0:
				if Match.current_game_mode == Match.GameMode.CPU_VS_CPU:
					self_player.restarter_throw_in_behaviour_cpu_team(self_player.get_parent().restarter_throw_in)
		Match.RestartingState.THROW_IN_R_0:
			if self_player.own_team == 0:
				if Match.current_game_mode == Match.GameMode.CPU_VS_CPU:
					self_player.restarter_throw_in_behaviour_user_team(self_player.get_parent().restarter_throw_in)
		Match.RestartingState.THROW_IN_L_1:
			if self_player.own_team == 1:
				self_player.restarter_throw_in_behaviour_cpu_team(self_player.get_parent().restarter_throw_in)
		Match.RestartingState.THROW_IN_R_1:
			if self_player.own_team == 1:
				self_player.restarter_throw_in_behaviour_cpu_team(self_player.get_parent().restarter_throw_in)
	match self_player.current_player_state:
		self_player.PlayerState.WITH_BALL:
			match self_player.current_player_with_ball:	
				self_player.PlayerWithBall.PASS:
					self_player.can_move = false
					self_player.get_node("TimerDecision").stop()
					self_player.choice_reveicer()
					self_player.pass_ball(Match.receiver)
