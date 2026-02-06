extends Node

func with_ball(self_player, Match, ball):
	if_in_shoot_area(self_player)
	set_and_play_timer_decision(self_player)
	match self_player.current_player_with_ball:
		self_player.PlayerWithBall.GO_TO_ATTACK_POSITION:
			go_to_attack_position(self_player)
		self_player.PlayerWithBall.SHOT_FTF:
			shot_ftf(self_player, Match, ball)
		self_player.PlayerWithBall.SHOT:
			shot(self_player)
		self_player.PlayerWithBall.PASS:
			pass_ball(self_player, Match)

			

func go_to_attack_position(self_player):
	self_player.can_move = true
	self_player.target = Vector2(self_player.default_position.x, \
		-195 * self_player.get_parent().team_multip)


func shot_ftf(self_player, Match, ball):
	self_player.can_move = false
	self_player.get_node("TimerDecision").stop()
	var target_goal
	var rival_goal = self_player.get_parent().rival_goal
	match Match.current_input_buffer_direction:
		Match.InputBufferDirection.LEFT:
			target_goal = rival_goal.get_node("TargetShot/TargetShot1").global_position
			print("Auto patear izquierda")
		Match.InputBufferDirection.RIGHT:
			target_goal = rival_goal.get_node("TargetShot/TargetShot2").global_position
			print("Auto patear derecha")
		Match.InputBufferDirection.FORWARD:
			target_goal = Vector2(ball.global_position.x, -180)
			print("Auto patear adelante")
	self_player.shot(target_goal)


func shot(self_player):
	self_player.can_move = false
	self_player.get_node("TimerDecision").stop()
	self_player.shot(self_player.choice_target_shot(self_player.get_parent().rival_goal))


func pass_ball(self_player, Match):
	self_player.can_move = false
	self_player.get_node("TimerDecision").stop()
	Match.receiver = self_player.choice_reveicer()
	self_player.pass_ball(Match.receiver)


# SUPPORT FUNCTIONS
# -----------------
			
func if_in_shoot_area(self_player):
	if self_player.in_shot_area and self_player.own_team == 1:
		if self_player.current_player_with_ball != self_player.PlayerWithBall.SHOT:
			self_player.current_player_with_ball = self_player.PlayerWithBall.SHOT
			self_player.behavior_tree()
			return
			
			
func set_and_play_timer_decision(self_player):
	randomize()
	var rand_time_decision : float = randf_range(0.2, self_player.time_decision)
	self_player.get_node("TimerDecision").wait_time = rand_time_decision
	self_player.get_node("TimerDecision").start()
