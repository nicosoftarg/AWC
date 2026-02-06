extends Node

func in_game(Match, self_gk, ball):
	match self_gk.current_player_state:
		self_gk.PlayerState.WITH_BALL:
			with_ball(self_gk, ball)
		self_gk.PlayerState.PASSING:
			passing(Match, self_gk, ball)
		self_gk.PlayerState.GO_TO_IMPACT_POINT:
			go_to_impact_point(self_gk)
		self_gk.PlayerState.BOUNCING:
			bouncing(self_gk)
		self_gk.PlayerState.SAVING:
			saving(self_gk)


						
func with_ball(self_gk, ball):	
	ball.linear_velocity = Vector2.ZERO
	self_gk.look_at(self_gk.get_parent().rival_goal.global_position)
	ball.current_ball_move_machine = ball.BallMoveMachine.IDLE
	ball.move_machine()
	await get_tree().create_timer(0.8).timeout
	self_gk.current_save_side = self_gk.SaveSide.CENTER
	self_gk.get_node("AnimatedSprite2D").play("center_save")
	self_gk.target = self_gk.global_position
	await get_tree().create_timer(0.5).timeout
	self_gk.get_node("AnimatedSprite2D").play("up_kick")
	await get_tree().create_timer(0.3).timeout
	self_gk.current_player_state = self_gk.PlayerState.PASSING
	self_gk.behavior_tree()
	
	
func passing(Match, self_gk, ball):
	Match.receiver = self_gk.get_parent().field_player_list.pick_random()
	self_gk.look_at(Match.receiver.global_position)
	self_gk.pass_target = Match.receiver.global_position
	Match.receiver.current_player_state = Match.receiver.PlayerState.RECEIVER
	if ball.player_with_ball == self_gk:
		ball.ball_in_hand = false
		ball.player_with_ball = null
		self_gk.set_collision_mask_value(2, false)
		var dir = ball.global_position.direction_to(self_gk.pass_target)
		dir = dir.normalized()
		var impulse = dir * self_gk.pass_power
		ball.linear_velocity = Vector2.ZERO
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		var distance = self_gk.global_position.distance_to(self_gk.pass_target)
		ball.set_max_ball_height(distance, self_gk.pass_power, 0)
		#ball.set_ball_height(distance, pass_power)
		await get_tree().create_timer(1.0).timeout
		self_gk.can_move = true
		self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION
		Match.match_state_changed.emit()
		self_gk.set_collision_mask_value(2, true)
		self_gk.get_node("RightSide").set_collision_mask_value(8, true)
		self_gk.get_node("LeftSide").set_collision_mask_value(8, true)
		self_gk.get_node("CenterSide").set_collision_mask_value(8, true)
		self_gk.behavior_tree()
			
			
func go_to_impact_point(self_gk):
	self_gk.target = self_gk.impact_point

	
func bouncing(self_gk):					
	self_gk.look_at(self_gk.get_parent().rival_goal.global_position)
	self_gk.get_node("AnimatedSprite2D").play("save")
	await get_tree().create_timer(1.5).timeout
	self_gk.can_move = true
	self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION
	
	
func saving(self_gk):
	self_gk.look_at(self_gk.get_parent().rival_goal.global_position)
	self_gk.last_state = self_gk.current_player_state
	self_gk.target = self_gk.global_position
	self_gk.get_node("AnimatedSprite2D").play("save")
	await get_tree().create_timer(1.5).timeout
	self_gk.can_move = true
	self_gk.current_player_state = self_gk.PlayerState.GO_TO_GK_POSITION
