extends Node

@onready var root : Area2D = $"../.."

enum DefenseZoneState {
	NOTHING,
	IN,
	OUT,
}

enum NearestPlayerState{
	NOTHING,
	IN,
	OUT,
}

var current_defense_zone_state : DefenseZoneState = DefenseZoneState.NOTHING
var current_nearest_player_state : NearestPlayerState = NearestPlayerState.NOTHING

func _physics_process(_delta):
	if root.Match.current_match_state == root.Match.MatchState.IN_GAME:
		if root.can_move:
			defense_zone_machine()		 


func defense_zone_machine():
	match current_defense_zone_state:
		DefenseZoneState.NOTHING:
			pass
		DefenseZoneState.IN:
			if root.current_player_state != root.PlayerState.GO_TO_BALL_ATTACK:
				if root.ball.player_with_ball:
					if root.ball.player_with_ball.own_team != root.own_team:
						root.current_player_state = root.PlayerState.GO_TO_BALL_ATTACK
						root.at_target = false
						root.move = true
						root.get_node("DefenseZone/DevSprite").modulate.a = 0.5
				else:
					if root.current_player_state != root.PlayerState.RECEIVER:
						if root.Match.player_controlled != root:
							root.at_target = false
							root.move = true
							root.current_player_state = root.PlayerState.GO_TO_BALL_ATTACK
							root.get_node("DefenseZone/DevSprite").modulate.a = 0.5 
		DefenseZoneState.OUT:
			if root.current_player_state != root.PlayerState.GO_TO_POSITION:
				if root.ball.player_with_ball:
					if root.ball.player_with_ball.own_team != root.own_team:
						if root.Match.player_controlled != root:
							root.current_player_state = root.PlayerState.GO_TO_POSITION
							root.get_node("DefenseZone/DevSprite").modulate.a = 0.0
							root.behavior_tree()
				else:
					if root.current_player_state != root.PlayerState.RECEIVER:
						if root.Match.player_controlled != root:
							root.current_player_state = root.PlayerState.GO_TO_POSITION
							root.get_node("DefenseZone/DevSprite").modulate.a = 0.0
							root.behavior_tree()
				current_defense_zone_state = DefenseZoneState.NOTHING
					 
			
		

	
