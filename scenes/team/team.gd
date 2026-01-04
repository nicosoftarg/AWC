extends Node2D

@export var shirt_color : Color
@export var team : int = 0
@export var restarter1 : Area2D
@export var restarter2 : Area2D
@export var restarter_corner : Area2D
@export var restarter_goal_kick : Area2D
var restarter_throw_in : Area2D
@export var restarter_throw_in_l : Area2D
@export var restarter_throw_in_r : Area2D
@export var team_multip : int
@export var rival_goal : Node2D
@export var own_goal : Node2D
@onready var Match = get_tree().get_first_node_in_group("match")
var field_player_list : Array[Area2D]
var attack_line : int
var defend_line : int
var goals : int = 0
@export var team_palette : Texture2D
@export var celebration_l : Marker2D
@export var celebration_r : Marker2D

var corner_receivers : Array[Area2D]
var corner_defenders : Array[Area2D]

var user_player_speed : float
var	cpu_player_speed : float
var	gk_player_speed : float
var	time_decision : float
var in_pass_area : Array[Area2D]
var player_for_ball : Area2D
@onready var ball = get_tree().get_first_node_in_group("ball")

func _physics_process(_delta):
	if Match.current_game_mode == Match.GameMode.CPU_VS_CPU or team == 1:
		if Match.current_match_state == Match.MatchState.IN_GAME:
			if Match.current_team_posesion != team or ball.player_with_ball == null:
				player_for_ball = search_nearest_player()
				player_for_ball.current_player_state = player_for_ball.PlayerState.GO_TO_BALL_ATTACK
			#elif Match.current_team_posesion == team and player_for_ball != ball.player_with_ball:
				#player_for_ball.current_player_state = player_for_ball.PlayerState.GO_TO_POSITION	
			

		
func search_nearest_player() -> Area2D:
	var min_distance : float = field_player_list[1].global_position.distance_squared_to(ball.global_position)
	var min_point : Area2D = field_player_list[1]
	for player in field_player_list:
		if player.can_move or Match.current_match_state == Match.MatchState.POSITIONING:
			if !player.user_controlled:
				var distance = player.global_position.distance_squared_to(ball.global_position)
				if distance < min_distance:
					min_distance = distance
					min_point = player
	return min_point


func _ready():
	#set_cpu_team()
	#set_team_palette()
	set_list_field_players()
	set_lines()
	append_corner_receivers()
	#call_deferred("set_cpu_team")
	call_deferred("set_team_palette")
	call_deferred("set_player_level")




#func set_cpu_team():
	#Global.set_cpu_team()

func set_team_palette():
	var id : int
	if team == 0:
		id = Global.InfoUserGame.current_user_team
	else:
		id = Global.InfoUserGame.current_rival_team
	
	team_palette = Global.get_data("Teams", id, "palette")


func set_player_level():
	var id : int
	if team == 0:
		id = Global.InfoUserGame.current_user_team
	else:
		id = Global.InfoUserGame.current_rival_team
	
	var level_team = Global.get_data("Teams", id, "level")
	user_player_speed = Global.get_data("Levels", level_team, "field_player_speed")
	cpu_player_speed = Global.get_data("Levels", level_team, "field_player_speed")
	gk_player_speed = Global.get_data("Levels", level_team, "gk_player_speed")
	time_decision = Global.get_data("Levels", level_team, "decision_time")



func append_corner_receivers():
	corner_receivers.append($FieldPlayer8)
	corner_receivers.append($FieldPlayer9)
	corner_receivers.append($FieldPlayer10)
	corner_defenders.append($FieldPlayer2)
	corner_defenders.append($FieldPlayer3)
	corner_defenders.append($FieldPlayer4)
	corner_defenders.append($FieldPlayer5)
	corner_defenders.append($FieldPlayer6)
	corner_defenders.append($FieldPlayer7)
	corner_defenders.append($FieldPlayer8)
	
	

func set_list_field_players():
	field_player_list.append($FieldPlayer1)
	field_player_list.append($FieldPlayer2)
	field_player_list.append($FieldPlayer3)
	field_player_list.append($FieldPlayer4)
	field_player_list.append($FieldPlayer5)
	field_player_list.append($FieldPlayer6)
	field_player_list.append($FieldPlayer7)
	field_player_list.append($FieldPlayer8)
	field_player_list.append($FieldPlayer9)
	field_player_list.append($FieldPlayer10)

func set_lines():
	if team == 0:
		attack_line = Match.n_attack_line 
		defend_line = Match.s_attack_line
	else:
		attack_line = Match.s_attack_line 
		defend_line = Match.n_attack_line
		 
func corner_position():
	corner_receivers[0].target = Vector2(Match.corner_position_1.global_position.x, Match.corner_position_1.global_position.y * team_multip)
	print(corner_receivers[0].name, str(corner_receivers[0].target))
	#corner_receivers[0].at_target = false
	corner_receivers[1].target = Vector2(Match.corner_position_2.global_position.x, Match.corner_position_2.global_position.y * team_multip)  
	#corner_receivers[1].at_target = false
	corner_receivers[2].target = Vector2(Match.corner_position_3.global_position.x, Match.corner_position_3.global_position.y * team_multip)    
	#corner_receivers[2].at_target = false
	
func set_corner_defenders():
	corner_defenders[0].target = Vector2(Match.corner_defender_position_1.global_position.x, Match.corner_defender_position_1.global_position.y * team_multip)
	corner_defenders[1].target = Vector2(Match.corner_defender_position_2.global_position.x, Match.corner_defender_position_2.global_position.y * team_multip)
	corner_defenders[2].target = Vector2(Match.corner_defender_position_3.global_position.x, Match.corner_defender_position_3.global_position.y * team_multip)
	corner_defenders[3].target = Vector2(Match.corner_defender_position_4.global_position.x, Match.corner_defender_position_4.global_position.y * team_multip)
	corner_defenders[4].target = Vector2(Match.corner_defender_position_5.global_position.x, Match.corner_defender_position_5.global_position.y * team_multip)
	corner_defenders[5].target = Vector2(Match.corner_defender_position_6.global_position.x, Match.corner_defender_position_6.global_position.y * team_multip)
	corner_defenders[6].target = Vector2(Match.corner_defender_position_7.global_position.x, Match.corner_defender_position_7.global_position.y * team_multip)
