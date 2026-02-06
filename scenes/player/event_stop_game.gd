extends Node

func stop_game(self_player, Match):
	match self_player.current_player_state:
		self_player.PlayerState.GO_TO_CELEBRATION:
			go_to_celebration(self_player, Match)
		_:
			self_player.target = self_player.global_position


func go_to_celebration(self_player, Match):
	var rival_gk = get_rival_gk(self_player, Match)
	Match.goal_scorer = get_goal_scorer(self_player, Match, rival_gk)
	if Match.goal_scorer == self_player:
		self_player.target = get_target(self_player, Match)
		self_player.get_node("AnimatedSprite2D").play("goal_scorer")
	else:
		self_player.get_node("AnimatedSprite2D").play("goal_no_scorer")
	self_player.move = true
	self_player.can_move = true		
	

# SUPPORT FUNCTIONS
# ----------------

func get_rival_gk(self_player, Match) -> Area2D:
	match self_player.own_team:
		0:
			return Match.gk_1
		_:
			return Match.gk_0
			
			
func get_goal_scorer(self_player, Match, rival_gk) -> Area2D:
	if rival_gk.shooter:
		return rival_gk.shooter
	else:
		if Match.last_player_touch_ball.own_team != rival_gk.own_team:
			return Match.last_player_touch_ball
		else:
			return self_player.get_parent().get_node("FieldPlayer9")
			
			
func get_target(self_player, Match) -> Vector2:
	if Match.goal_scorer_position.x > 0:
		return self_player.get_parent().celebration_l.global_position			
	else:
		return self_player.get_parent().celebration_r.global_position
