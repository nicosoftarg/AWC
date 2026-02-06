extends Node

		
func animations_state_machine(Match, self_gk, ball):
	match self_gk.current_player_state:
		self_gk.PlayerState.GO_TO_GK_POSITION:
			go_to_gk_position(Match, self_gk, ball)
		self_gk.PlayerState.GO_TO_IMPACT_POINT:	
			go_to_impact_point(Match, self_gk, ball)
		self_gk.PlayerState.GO_TO_BALL:
			self_gk.target = ball.global_position
			self_gk.look_at(ball.global_position)
		self_gk.PlayerState.WITH_BALL:
			self_gk.can_move = false
		self_gk.PlayerState.SAVING:
			#self_gk.can_move = false
			saving(Match, self_gk)
		self_gk.PlayerState.BOUNCING:
			self_gk.last_state = self_gk.PlayerState.BOUNCING
			self_gk.can_move = false
	can_move_animations(self_gk)


func can_move_animations(self_gk):
	if self_gk.can_move:
		if at_target(self_gk):
			self_gk.get_node("AnimatedSprite2D").play("idle")
			self_gk.move = false
		else:
			self_gk.get_node("AnimatedSprite2D").play("run")
			self_gk.move = true


func at_target(self_gk) -> bool:
	var distance_to_target : float = self_gk.global_position.distance_to(self_gk.target)
	if distance_to_target > 3:
		return false
	else:
		return true
		

func go_to_gk_position(Match, self_gk, _ball):
	match Match.current_match_state:
		Match.MatchState.RESTARTING:
			if self_gk.own_team == 0:
				self_gk.target = Vector2(self_gk.own_goal.gk_position.global_position.x, 165)
			else:
				self_gk.target = Vector2(self_gk.own_goal.gk_position.global_position.x, -165)
		Match.MatchState.IN_GAME:
			self_gk.look_at(self_gk.target)
			#if self_gk.move:
				#self_gk.look_at(self_gk.target)
			#else:
				#self_gk.look_at(ball.global_position)
			self_gk.target = self_gk.search_nearest_position()
		Match.MatchState.STOP_GAME:
			if self_gk.can_move:
				self_gk.target = self_gk.global_position
		Match.MatchState.POSITIONING:
			self_gk.target = self_gk.search_nearest_position()
			self_gk.current_save_side = self_gk.SaveSide.CENTER
			self_gk.hand = self_gk.center_hand
			self_gk.get_node("RightSide").set_collision_mask_value(8, true)
			self_gk.get_node("LeftSide").set_collision_mask_value(8, true)
			
				
func go_to_impact_point(Match, self_gk, ball):
	if Match.current_match_state == Match.MatchState.IN_GAME:
		if self_gk.own_team == 0:
			if ball.global_position.y > self_gk.global_position.y -10:
				self_gk.look_at(self_gk.get_parent().rival_goal.global_position)
				if self_gk.impact_point.x > self_gk.global_position.x and self_gk.impact_point.x < self_gk.impact_point.x + 6 :
					self_gk.saving(self_gk.SaveSide.RIGHT)
				else:
					self_gk.saving(self_gk.SaveSide.LEFT)
			else:
				self_gk.look_at(self_gk.target)
		else:
			if ball.global_position.y < self_gk.global_position.y +10:
				self_gk.look_at(self_gk.get_parent().rival_goal.global_position)
				if self_gk.impact_point.x > self_gk.global_position.x:
					self_gk.saving(self_gk.SaveSide.LEFT)
				else:
					self_gk.saving(self_gk.SaveSide.RIGHT)
			else:
				self_gk.look_at(self_gk.target)
	else:
		if self_gk.can_move:
			self_gk.target = self_gk.global_positoin
			self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION

			
			


func go_to_ball(Match, self_gk, ball):
	if Match.current_match_state == Match.MatchState.IN_GAME:
		self_gk.target = ball.global_position
	else:
		if self_gk.can_move:
			self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION
	
func saving(Match, self_gk):
	if Match.current_match_state == Match.MatchState.IN_GAME:
		self_gk.can_move = false
	#else:
		#self_gk.can_move = true
		#self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION
