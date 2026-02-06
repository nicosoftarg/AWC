extends Node

@onready var event_stop_game = $EventStopGame
@onready var event_positioning = $EventPositioning
@onready var event_restarting = $EventRestarting
@onready var event_in_game = $EventInGame


func event_behavior_tree(self_player, Match, ball):
	match Match.current_match_state:
		Match.MatchState.STOP_GAME:
			event_stop_game.stop_game(self_player, Match)
		Match.MatchState.POSITIONING:
			event_positioning.positioning(self_player, Match)
		Match.MatchState.RESTARTING:
			event_restarting.restarting(self_player, Match, ball)
		Match.MatchState.IN_GAME:
			event_in_game.in_game(self_player, Match, ball)

	self_player.move_animations()
	set_distance_behavior(self_player, ball)
	

func set_distance_behavior(self_player, ball):
	var distance_to_target : float = self_player.global_position.distance_to(self_player.target)
	if distance_to_target > 5:
		self_player.move = true
		if self_player.current_player_state != self_player.PlayerState.USER_CONTROLLED:
			self_player.at_target = false
		if self_player.move and self_player.can_move:
			self_player.look_at(self_player.target)
	else:
		if self_player.current_player_state != self_player.PlayerState.USER_CONTROLLED:
			self_player.move = false
			self_player.at_target = true
		if !self_player.move and self_player.can_move:
			self_player.look_at(ball.global_position)


func go_to_position(self_player, Match): 
	self_player.can_move = true
	if Match.current_team_posesion == self_player.own_team:
		team_possession(self_player, Match, Match.current_team_posesion)		
	else:
		if Match.current_team_posesion == 0:
			no_team_possession(self_player, Match, 1)
		else:
			no_team_possession(self_player, Match, 0)	
	set_target_and_look_at(self_player)


# SUPPORT FUNCTIONS
# -----------------

func team_possession(self_player, Match, team):
	if !self_player.static_position:
		if self_player.own_team == team:
			self_player.dinamic_position.global_position.y = get_attacking_position(self_player, Match, team)		
		self_player.dinamic_position.global_position = set_nearest_position(self_player.dinamic_position.global_position)
		self_player.dinamic_position_corrected(self_player.dinamic_position.global_position)		
	else:
		self_player.dinamic_position.global_position.y = self_player.dinamic_position.global_position.y
	
	
func no_team_possession(self_player, Match, team):
	if !self_player.static_position:
		if team == 0:
			if positioning_and_goal_kick(self_player.own_team, Match, Match.MatchState.POSITIONING):
				rival_goal_kick_positioning(self_player)
			else:
				self_player.dinamic_position.global_position.y = get_defending_position(self_player, Match, team)
		else:
			if positioning_and_goal_kick(self_player.own_team, Match, Match.MatchState.POSITIONING):
				rival_goal_kick_positioning(self_player)
			else:
				self_player.dinamic_position.global_position.y = get_defending_position(self_player, Match, team)		


func set_target_and_look_at(self_player):
	self_player.target = self_player.dinamic_position.global_position
	self_player.look_at(self_player.target)	

	
func get_attacking_position(self_player, Match, team) -> float:
	match Match.current_tactic_zone:
		Match.TacticZone.ZONE_A:
			if team == 0:
				return get_attack_return(self_player)
			else:
				return self_player.default_position.y
		Match.TacticZone.ZONE_C:
			if team == 0:
				return self_player.default_position.y
			else:
				return get_attack_return(self_player)
		_:
			if team == 0:
				return get_attack_return(self_player)
			else:
				return get_attack_return(self_player)


func get_defending_position(self_player, Match, team) -> float:
	match Match.current_tactic_zone:
		Match.TacticZone.ZONE_A:
			if team == 0:
				return self_player.default_position.y
			else:
				return get_defense_return(self_player)
		Match.TacticZone.ZONE_C:
			if team == 0:
				return get_defense_return(self_player)
			else:
				return self_player.default_position.y
		_:
			if team == 0:
				return get_defense_return(self_player)
			else:
				return get_defense_return(self_player)	


func get_attack_return(self_player) -> float:
	return self_player.default_position.y - (40 * self_player.get_parent().team_multip)
	

func get_defense_return(self_player) -> float:
	return self_player.default_position.y + (60 * self_player.get_parent().team_multip)


func positioning_and_goal_kick(team, Match, match_state) -> bool:
	if Match.current_match_state == match_state:
		if team == 0 and Match.current_restarting_state == Match.RestartingState.GOAL_KICK_1:
			return true
		elif team == 1 and Match.current_restarting_state == Match.RestartingState.GOAL_KICK_0:
			return true
		else:
			return false
	else:
		return false


func rival_goal_kick_positioning(self_player):
	self_player.dinamic_position.global_position.x = self_player.default_position.x
	self_player.dinamic_position.global_position.y = self_player.default_position.y + (20 * self_player.get_parent().team_multip)


func set_nearest_position(pos) -> Vector2: 
	randomize()
	var rand_nearest_x = randi_range(-5, 5)
	var rand_nearest_y = randi_range(-3, 3)
	return Vector2(pos.x + rand_nearest_x, pos.y + rand_nearest_y)
