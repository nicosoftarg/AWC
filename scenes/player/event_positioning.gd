extends Node

func positioning(self_player, Match):
	self_player.can_move = true
	match Match.current_restarting_state:
		Match.RestartingState.KICK_OFF:
			kick_off(self_player, Match)
		Match.RestartingState.GOAL_KICK_0:
			goal_kick(0, self_player, Match)
		Match.RestartingState.GOAL_KICK_1:
			goal_kick(1, self_player, Match)
		Match.RestartingState.CORNER_KICK_L_0:
			corner_kick(0, Match.corner_kick_l_0.global_position, self_player)
		Match.RestartingState.CORNER_KICK_R_0:
			corner_kick(0, Match.corner_kick_r_0.global_position, self_player)
		Match.RestartingState.CORNER_KICK_L_1:
			corner_kick(1, Match.corner_kick_l_1.global_position, self_player)
		Match.RestartingState.CORNER_KICK_R_1:
			corner_kick(1, Match.corner_kick_r_1.global_position, self_player)				
		Match.RestartingState.THROW_IN_L_0:
			throw_in(0, Match.throw_in_l.global_position, self_player)
		Match.RestartingState.THROW_IN_R_0:
			throw_in(0, Match.throw_in_r.global_position, self_player)
		Match.RestartingState.THROW_IN_L_1:
			throw_in(1, Match.throw_in_r.global_position, self_player)
		Match.RestartingState.THROW_IN_R_1:
			throw_in(1, Match.throw_in_l.global_position, self_player)
	
	match self_player.current_player_state:
		self_player.PlayerState.GO_TO_POSITION:
			get_parent().go_to_position(self_player, Match)
		self_player.PlayerState.GO_TO_KICKOFF_POSITION:
			self_player.global_position = self_player.kick_off_position	
			self_player.target = self_player.global_position
		self_player.PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_1:
			self_player.global_position = Match.restarter_point_1.global_position
			self_player.target = self_player.global_position
		self_player.PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_2:
			self_player.global_position = Match.restarter_point_2.global_position
			self_player.target = self_player.global_position
		self_player.PlayerState.GO_TO_CORNER_POSITION:
			self_player.target = get_corner_defender_position(Match, self_player, self_player.name)

			

func kick_off(self_player, Match):
	if Match.current_team_posesion == self_player.own_team:
		if self_player.get_parent().restarter1 == self_player:
			self_player.current_player_state = self_player.PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_1
		elif self_player.get_parent().restarter2 == self_player:
			self_player.current_player_state = self_player.PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_2
			
		else:
			self_player.current_player_state = self_player.PlayerState.GO_TO_KICKOFF_POSITION
	else:
		self_player.current_player_state = self_player.PlayerState.GO_TO_KICKOFF_POSITION


func goal_kick(team, self_player, Match):
	if self_player.own_team == team:
		if self_player.get_parent().restarter_goal_kick == self_player:
			if team == 0:
				self_player.target = Match.goal_kick_point_0.global_position
			else:
				self_player.target = Match.goal_kick_point_1.global_position
			self_player.current_player_state = self_player.PlayerState.RESTARTER	
		else:
			self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
	else:
		self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION


func corner_kick(team, target, self_player):
	if self_player.own_team == team:
		if self_player.get_parent().restarter_corner == self_player:
			self_player.target = target
			self_player.current_player_state = self_player.PlayerState.RESTARTER
		else:
			self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
			self_player.get_parent().corner_position()
	else:
		if self_player.corner_defender:
			self_player.current_player_state = self_player.PlayerState.GO_TO_CORNER_POSITION
			#self_player.behavior_tree()
		else:
			self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
			#self_player.behavior_tree()
		#self_player.get_parent().set_corner_defenders()
		

func throw_in(team, target, self_player):
	self_player.ball.current_ball_height_machine = self_player.ball.BallHeightMachine.HEAD
	self_player.ball.height_machine()
	if self_player.own_team == team:
		if self_player.get_parent().restarter_throw_in == self_player:
			self_player.set_collision_mask_value(2,false)
			self_player.target = target
			self_player.current_player_state = self_player.PlayerState.RESTARTER
		else:
			self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
	else:
		self_player.current_player_state = self_player.PlayerState.GO_TO_POSITION
	
	
func get_corner_defender_position(Match, self_player, name_player) -> Vector2:
	match name_player:
		"FieldPlayer1":
			return Vector2(Match.corner_defender_position_1.global_position.x, Match.corner_defender_position_1.global_position.y * self_player.get_parent().team_multip)
		"FieldPlayer2":
			return Vector2(Match.corner_defender_position_2.global_position.x, Match.corner_defender_position_2.global_position.y * self_player.get_parent().team_multip)
		"FieldPlayer3":
			return Vector2(Match.corner_defender_position_3.global_position.x, Match.corner_defender_position_3.global_position.y * self_player.get_parent().team_multip)
		"FieldPlayer4":
			return Vector2(Match.corner_defender_position_4.global_position.x, Match.corner_defender_position_4.global_position.y * self_player.get_parent().team_multip)
		"FieldPlayer5":
			return Vector2(Match.corner_defender_position_5.global_position.x, Match.corner_defender_position_5.global_position.y * self_player.get_parent().team_multip)
		"FieldPlayer6":
			return Vector2(Match.corner_defender_position_6.global_position.x, Match.corner_defender_position_6.global_position.y * self_player.get_parent().team_multip)
		"FieldPlayer7":
			return Vector2(Match.corner_defender_position_7.global_position.x, Match.corner_defender_position_7.global_position.y * self_player.get_parent().team_multip)
		_:
			return self_player.default_position
	
