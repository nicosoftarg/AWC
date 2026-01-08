extends Node2D

signal match_state_changed

@onready var impact_x = $impact_x

@export_file('*.tscn') var match_preview
@export_file('*.tscn') var portada
@export_file('*.tscn') var victory
@export var touch_gamepad : bool = false

const n_attack_line : int = -65
const s_attack_line : int = 65
const limit_line : int = -175

const GAME_FIELD_MARGIN : Vector2 = Vector2(115, 145)

const RADAR_SIZE : Vector2 = Vector2(20, 15)

enum GameMode {
	PLAYER_VS_CPU,
	CPU_VS_CPU,
	PLAYER_VS_PLAYER,
}
@export var current_game_mode : GameMode = GameMode.PLAYER_VS_CPU

enum MatchState {
	IN_GAME,
	RESTARTING,
	STOP_GAME,
	POSITIONING,
	TIME_UP,
	CHAMPION_CELEBRATION,
}

enum RestartingState {
	KICK_OFF,
	GOAL_KICK_0,
	GOAL_KICK_1,
	CORNER_KICK_L_0,
	CORNER_KICK_R_0,
	CORNER_KICK_L_1,
	CORNER_KICK_R_1,
	THROW_IN_L_0,
	THROW_IN_R_0,
	THROW_IN_L_1,
	THROW_IN_R_1,
}

enum InputBufferActions {
	NOTHING,
	SHOOT,
	PASS,
}

enum InputBufferDirection {
	FORWARD,
	RIGHT,
	LEFT,
}

# Variables externas, el tiempo se podría cambiar
@export var default_time : int = 90
var time : int 

var current_match_state : MatchState = MatchState.POSITIONING
var current_restarting_state : RestartingState = RestartingState.KICK_OFF
var current_team_posesion : int = 0



var receiver : Area2D
var saver_goalkeeper : Area2D
var last_player_touch_ball : Area2D
var goal_scorer : Area2D
var goal_scorer_position : Vector2
var player_controlled : Area2D
var restarter : Area2D


@onready var ball = $Ball
@onready var restarter_point_1: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/RestarterPoint1
@onready var restarter_point_2: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/RestarterPoint2

@onready var cpu_scorer = $CanvasLayer/Panel/CpuScorer
@onready var two_points = $CanvasLayer/Panel/TwoPoints
@onready var user_scorer = $CanvasLayer/Panel/CpuScorer2
@onready var time_1 = $CanvasLayer/Panel/Time1
@onready var two_points_2 = $CanvasLayer/Panel/TwoPoints2
@onready var time_2 = $CanvasLayer/Panel/Time2
@onready var game_time = $GameTime

@onready var gk_0: Area2D = $Players/Team0/Gk
@onready var gk_1: Area2D = $Players/Team1/Gk

@onready var audio_shot: AudioStreamPlayer = $SFX/Shot

# Input Buffer
var current_input_buffer_action : InputBufferActions = InputBufferActions.NOTHING
var current_input_buffer_direction : InputBufferDirection = InputBufferDirection.FORWARD


# RESTARTER PLAYER POINTS
@onready var goal_kick_point_0: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/GoalKickPoint0
@onready var goal_kick_point_1: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/GoalKickPoint1
@onready var corner_kick_l_0: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/CornerKickL0
@onready var corner_kick_l_1: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/CornerKickL1
@onready var corner_kick_r_0: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/CornerKickR0
@onready var corner_kick_r_1: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/CornerKickR1
@onready var throw_in_l: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/ThrowInL
@onready var throw_in_r: Marker2D = $Stage/RestartPoints/RestartPlayerPoints/ThrowInR
@onready var corner_position_1: Marker2D = $Stage/RestartPoints/CornersReceiversPoint/CornerPosition1
@onready var corner_position_2: Marker2D = $Stage/RestartPoints/CornersReceiversPoint/CornerPosition2
@onready var corner_position_3: Marker2D = $Stage/RestartPoints/CornersReceiversPoint/CornerPosition3
@onready var corner_defender_position_1: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition1
@onready var corner_defender_position_2: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition2
@onready var corner_defender_position_3: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition3
@onready var corner_defender_position_4: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition4
@onready var corner_defender_position_5: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition5
@onready var corner_defender_position_6: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition6
@onready var corner_defender_position_7: Marker2D = $Stage/RestartPoints/CornersDefendersPoint/CornerDefenderPosition7

@onready var restarting_label: Label = $CanvasLayer/RestartingLabel
@onready var match_label: Label = $CanvasLayer/MatchLabel
@onready var shadow_ball = $ShadowBallNode/ShadowBall
@onready var champions_point : Array = get_tree().get_nodes_in_group("champion_point") 
@onready var palo: AudioStreamPlayer = $SFX/Palo


var players_in_camera : Array[Area2D]


func _ready() -> void:
	get_tree().paused = false
	set_touch_gamepad(touch_gamepad)
	time = default_time
	#Global.dbase_create()
	match_label.text = Global.set_text_week()
	$Stage/Goal0.Goal.connect(_on_goal_scored)
	$Stage/Goal1.Goal.connect(_on_goal_scored)
	if current_game_mode == GameMode.PLAYER_VS_CPU:
		player_controlled = $Players/Team0/FieldPlayer6
		$UserArrows.visible = true
		player_controlled.current_player_state = player_controlled.PlayerState.USER_CONTROLLED
		player_controlled.move = true
		player_controlled.user_controlled = true
		$UserArrows.play("default")
	process_match_states()
	call_deferred("set_supporters_palette")


func _physics_process(_delta: float) -> void:
	#$Camera2D.global_position = $Camera2D.global_position.round()
	radar()
	player_user_arrows()
	$ShadowBallNode.global_position = $Ball/AnimatedSprite2D.global_position
	if current_team_posesion == 0:
		$Camera2D.global_position = Vector2(ball.global_position.x, ball.global_position.y - 10)
	else:
		$Camera2D.global_position = Vector2(ball.global_position.x, ball.global_position.y + 10)
	lines_crossed()
	#if receiver:
		#$CanvasLayer/DevLabels/DevLabel1.text = str(receiver.name)
	#else:
		#$CanvasLayer/DevLabels/DevLabel1.text = "No hay receptor"
	#var suma_direction = abs(player_controlled.velocity.x) + abs(player_controlled.velocity.y)
	#$CanvasLayer/DevLabels/DevLabel2.text = str(suma_direction)
	#$CanvasLayer/DevLabels/DevLabel3.text = str(ball.get_collision_layer_value(8))
	
		
	
func set_touch_gamepad(condition : bool):
	if condition:
		$CanvasLayer/LeftControlsNew.visible = true
		$CanvasLayer/RightControls.visible = true
	else:
		$CanvasLayer/LeftControlsNew.visible = false
		$CanvasLayer/RightControls.visible = false


			
			

func lines_crossed():
	var error_margin = 1
	if ball.global_position.y > n_attack_line - error_margin and ball.global_position.y < n_attack_line + error_margin or \
		ball.global_position.y > s_attack_line - error_margin and ball.global_position.y < s_attack_line + error_margin:
		match_state_changed.emit()
		#print("Lineas cruzadas")
		


func player_user_arrows():
	if current_game_mode == GameMode.PLAYER_VS_CPU:
		if player_controlled:
			$UserArrows.global_position = Vector2(player_controlled.global_position.x, player_controlled.global_position.y + 8)


func game_time_manager():
	if current_match_state == MatchState.IN_GAME:
		time -= 1
		if time < 60:
			time_1.text = "0"
			if time > 9:
				time_2.text = str(time)
			else:
				time_2.text = "0" + str(time)
		else:
			var seconds : int = time
			if seconds > 59:
				seconds = time - 60
			else:
				seconds = time
			
			time_1.text = "1"
			if seconds > 9:
				time_2.text = str(seconds)
			else:
				time_2.text = "0" + str(seconds)
		if time == 0:
			$SFX/TimeOut.play()
			current_match_state = MatchState.TIME_UP
			process_match_states()
	
		


func process_match_states():
	match current_match_state:
		MatchState.IN_GAME:
			restarting_label.visible = false
			match_label.visible = false
		MatchState.STOP_GAME:	
			current_input_buffer_action = InputBufferActions.NOTHING
			current_input_buffer_direction = InputBufferDirection.FORWARD
			if receiver:
				receiver.current_player_state = receiver.PlayerState.GO_TO_POSITION
			#match_state_changed.emit()
			var wait_time
			if current_restarting_state == RestartingState.KICK_OFF:
				wait_time = 4.0
			else:
				wait_time = 0.1
			await get_tree().create_timer(wait_time).timeout
			#restarting_game()
			current_match_state = MatchState.POSITIONING
			match_state_changed.emit()
			process_match_states()
		MatchState.TIME_UP:
			get_tree().paused = true
			$CanvasLayer/RestartingLabel.visible = false
			match_label.visible = false
			$CanvasLayer/ColorRect.visible = true
			await get_tree().create_timer(2.0).timeout
			var goals_dif = $Players/Team0.goals - $Players/Team1.goals
			if goals_dif <= 0:
				$Music/GameOver.play()
				$CanvasLayer/RestartingLabel.rotation = 0.0
				$CanvasLayer/ColorRect/Label.visible = false
				restarting_label.text = "GAME OVER"
				restarting_label.visible = true
				await get_tree().create_timer(5.0).timeout
				Global.InfoUserGame.current_week = 1
				get_tree().change_scene_to_file.call_deferred(portada)
			else:
				if Global.InfoUserGame.current_week < 7:
					Global.InfoUserGame.current_week += 1
					get_tree().change_scene_to_file.call_deferred(match_preview)
				else:
					Global.InfoUserGame.current_week = 1
					get_tree().change_scene_to_file.call_deferred(victory)
					#$CanvasLayer/ColorRect/Label.visible = false
					#$CanvasLayer/RestartingLabel.rotation = 0.0
					#restarting_label.text = "VICTORY!!!"
				restarting_label.visible = true
		MatchState.POSITIONING:
			$ShadowBallNode/ShadowBall.play("h0")
			ball.linear_velocity = Vector2.ZERO
			ball.angular_velocity = 0.0
			$CanvasLayer/Goal.visible = false
			if current_team_posesion == 0:
				$CanvasLayer/RestartingLabel.rotation = 0.0
			else:
				$CanvasLayer/RestartingLabel.rotation = deg_to_rad(180)
			match current_restarting_state:
				RestartingState.KICK_OFF:
					restarting_label.text = "KICK OFF"
					restarting_label.visible = true
					match_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/KickOffPoint.global_position
					$SFX/Whistle.play()
					await get_tree().create_timer(0.8).timeout					
					$"Music/Track1-Match".play()
				RestartingState.GOAL_KICK_0:
					restarting_label.text = "GOAL KICK"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/GoalKick0.global_position
				RestartingState.GOAL_KICK_1:
					restarting_label.text = "GOAL KICK"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/GoalKick1.global_position
				RestartingState.CORNER_KICK_L_0:
					restarting_label.text = "CORNER KICK"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/CornerKickL0.global_position
				RestartingState.CORNER_KICK_R_0:
					restarting_label.text = "CORNER KICK"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/CornerKickR0.global_position
				RestartingState.CORNER_KICK_L_1:
					restarting_label.text = "CORNER KICK"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/CornerKickL1.global_position
				RestartingState.CORNER_KICK_R_1:
					restarting_label.text = "CORNER KICK"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/CornerKickR1.global_position
				RestartingState.THROW_IN_L_0:
					restarting_label.text = "THROW IN"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/ThrowInL.global_position
				RestartingState.THROW_IN_R_0:
					restarting_label.text = "THROW IN"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/ThrowInR.global_position
				RestartingState.THROW_IN_L_1:
					restarting_label.text = "THROW IN"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/ThrowInR.global_position
				RestartingState.THROW_IN_R_1:
					restarting_label.text = "THROW IN"
					restarting_label.visible = true
					ball.global_position = $Stage/RestartPoints/RestartBallPoints/ThrowInL.global_position
			var wait_time : float
			if current_restarting_state == RestartingState.KICK_OFF:
				wait_time = 1.0
			elif current_restarting_state == RestartingState.THROW_IN_R_0 or \
				current_restarting_state == RestartingState.THROW_IN_R_1 or \
				current_restarting_state == RestartingState.THROW_IN_L_0 or \
				current_restarting_state == RestartingState.THROW_IN_L_1:
					wait_time = 3.0
			else:
				wait_time = 2.0
			await get_tree().create_timer(wait_time).timeout
			if current_match_state != MatchState.IN_GAME:
				restarting_game()
		MatchState.RESTARTING:
			$RestartingTimer.start()	

func restarting_game():
	#await get_tree().create_timer(3.0).timeout
	#ball.linear_velocity = Vector2.ZERO
	#ball.angular_velocity = 0.0
	#ball.global_position = Vector2.ZERO
	current_match_state = MatchState.RESTARTING
	ball.set_collision_layer_value(2, true)
	ball.can_scored = true
	goal_scorer = null
	if time == default_time:
		game_time.start()
	#$CanvasLayer/Goal.visible = false
	#process_match_states()
	match_state_changed.emit()

func set_supporters_palette():
	$Stage/UserSupporters.material.set_shader_parameter("palette_to", $Players/Team0.team_palette)
	$Stage/CpuSupporters.material.set_shader_parameter("palette_to", $Players/Team1.team_palette)

func radar():
	#$"CanvasLayer/Control/player0-6".position.x = 5
	#$"CanvasLayer/Control/player0-6".position.y = 13
	$CanvasLayer/Control/ball.position = Vector2(5 + ball.position.x / RADAR_SIZE.x, 15 + ball.position.y / RADAR_SIZE.y )
	#$"CanvasLayer/Control/player0-1".position = Vector2(5 + $Players/Team0/FieldPlayer1.global_position.x / RADAR_SIZE.x, 15 + $Players/Team0/FieldPlayer0.global_position.y / RADAR_SIZE.y)
	$"CanvasLayer/Control/player0-1".position.x = 5 + $Players/Team0/FieldPlayer1.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-1".position.y = 14 +$Players/Team0/FieldPlayer1.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-2".position.x = 5 + $Players/Team0/FieldPlayer2.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-2".position.y = 14 +$Players/Team0/FieldPlayer2.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-3".position.x = 5 + $Players/Team0/FieldPlayer3.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-3".position.y = 14 +$Players/Team0/FieldPlayer3.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-4".position.x = 5 + $Players/Team0/FieldPlayer4.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-4".position.y = 14 +$Players/Team0/FieldPlayer4.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-5".position.x = 5 + $Players/Team0/FieldPlayer5.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-5".position.y = 14 +$Players/Team0/FieldPlayer5.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-6".position.x = 5 + $Players/Team0/FieldPlayer6.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-6".position.y = 14 +$Players/Team0/FieldPlayer6.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-7".position.x = 5 + $Players/Team0/FieldPlayer7.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-7".position.y = 14 +$Players/Team0/FieldPlayer7.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-8".position.x = 5 + $Players/Team0/FieldPlayer8.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-8".position.y = 14 +$Players/Team0/FieldPlayer8.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-9".position.x = 5 + $Players/Team0/FieldPlayer9.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-9".position.y = 14 +$Players/Team0/FieldPlayer9.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-10".position.x = 5 + $Players/Team0/FieldPlayer10.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-10".position.y = 14 +$Players/Team0/FieldPlayer10.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player0-gk".position.x = 5 + $Players/Team0/Gk.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player0-gk".position.y = 14 +$Players/Team0/Gk.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-1".position.x = 5 + $Players/Team1/FieldPlayer1.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-1".position.y = 14 +$Players/Team1/FieldPlayer1.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-2".position.x = 5 + $Players/Team1/FieldPlayer2.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-2".position.y = 14 +$Players/Team1/FieldPlayer2.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-3".position.x = 5 + $Players/Team1/FieldPlayer3.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-3".position.y = 14 +$Players/Team1/FieldPlayer3.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-4".position.x = 5 + $Players/Team1/FieldPlayer4.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-4".position.y = 14 +$Players/Team1/FieldPlayer4.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-5".position.x = 5 + $Players/Team1/FieldPlayer5.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-5".position.y = 14 +$Players/Team1/FieldPlayer5.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-6".position.x = 5 + $Players/Team1/FieldPlayer6.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-6".position.y = 14 +$Players/Team1/FieldPlayer6.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-7".position.x = 5 + $Players/Team1/FieldPlayer7.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-7".position.y = 14 +$Players/Team1/FieldPlayer7.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-8".position.x = 5 + $Players/Team1/FieldPlayer8.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-8".position.y = 14 +$Players/Team1/FieldPlayer8.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-9".position.x = 5 + $Players/Team1/FieldPlayer9.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-9".position.y = 14 +$Players/Team1/FieldPlayer9.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-10".position.x = 5 + $Players/Team1/FieldPlayer10.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-10".position.y = 14 +$Players/Team1/FieldPlayer10.global_position.y / RADAR_SIZE.y
	$"CanvasLayer/Control/player1-gk".position.x = 5 + $Players/Team1/Gk.global_position.x / RADAR_SIZE.x 
	$"CanvasLayer/Control/player1-gk".position.y = 14 +$Players/Team1/Gk.global_position.y / RADAR_SIZE.y
	



func _on_goal_scored(goal):
	$"Music/Track1-Match".stop()
	ball.set_collision_layer_value(2, false)
	ball.player_with_ball = null
	if goal.rival_team == 0:
		$Players/Team0.goals += 1
		user_scorer.text = str($Players/Team0.goals)
		current_team_posesion = 1
		$CanvasLayer/Goal.visible = true
		$CanvasLayer/Goal.play("Goal_User")
	else:
		$Players/Team1.goals += 1
		cpu_scorer.text = str($Players/Team1.goals)
		current_team_posesion = 0
		$CanvasLayer/Goal.visible = true
		$CanvasLayer/Goal.play("Goal_Cpu")
	current_match_state = MatchState.STOP_GAME
	current_restarting_state = RestartingState.KICK_OFF
	match_state_changed.emit()
	$SFX/GoalWhistle.play()
	await get_tree().create_timer(1.0).timeout
	$"Music/Track2-Goal".play()
	process_match_states()
	


func _on_game_time_timeout():
	if current_match_state == MatchState.IN_GAME:
		if time == 61 or time == 31:
			$SFX/TimeIndicator.play()
		elif time <12 and time > 1:
			$SFX/RegresiveCount.play()
		elif time <= 1:
			$"Music/Track1-Match".stop()
			await get_tree().create_timer(0.1).timeout
			$SFX/TimeOut.play()
			await get_tree().create_timer(0.1).timeout
	game_time_manager()


func _on_side_l_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		$SFX/Whistle.play()
		ball.set_collision_layer_value(2, false)
		ball.player_with_ball = null
		if last_player_touch_ball.own_team == 0:
			current_restarting_state = RestartingState.THROW_IN_R_1
			current_team_posesion = 1
			$Players/Team1.restarter_throw_in =	$Players/Team1.search_nearest_player()
		else:
			current_restarting_state = RestartingState.THROW_IN_L_0
			current_team_posesion = 0
			$Players/Team0.restarter_throw_in =	$Players/Team0.search_nearest_player()
	$Stage/RestartPoints/RestartBallPoints/ThrowInL.global_position.y = body.global_position.y
	$Stage/RestartPoints/RestartPlayerPoints/ThrowInL.global_position.y = body.global_position.y
	current_match_state = MatchState.STOP_GAME
	match_state_changed.emit()
	process_match_states()



func _on_side_r_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		$SFX/Whistle.play()
		ball.set_collision_layer_value(2, false)
		ball.player_with_ball = null
		if last_player_touch_ball.own_team == 0:
			current_restarting_state = RestartingState.THROW_IN_L_1
			current_team_posesion = 1
			$Players/Team1.restarter_throw_in =	$Players/Team1.search_nearest_player()
		else:
			current_restarting_state = RestartingState.THROW_IN_R_0
			current_team_posesion = 0
			$Players/Team0.restarter_throw_in =	$Players/Team0.search_nearest_player()
	$Stage/RestartPoints/RestartBallPoints/ThrowInR.global_position.y = body.global_position.y
	$Stage/RestartPoints/RestartPlayerPoints/ThrowInR.global_position.y = body.global_position.y
	current_match_state = MatchState.STOP_GAME
	match_state_changed.emit()
	process_match_states()


func _on_up_l_body_entered(body: Node2D) -> void:
	if current_match_state == MatchState.IN_GAME:
		$SFX/Whistle.play()
		ball.set_collision_layer_value(2, false)
		ball.player_with_ball = null
		if body is RigidBody2D:
			if last_player_touch_ball.own_team == 0:
				current_restarting_state = RestartingState.GOAL_KICK_1
				current_team_posesion = 1
			else:
				current_restarting_state = RestartingState.CORNER_KICK_L_0
				current_team_posesion = 0
		current_match_state = MatchState.STOP_GAME
		match_state_changed.emit()
		process_match_states()


func _on_up_r_body_entered(body: Node2D) -> void:
	if current_match_state == MatchState.IN_GAME:
		$SFX/Whistle.play()
		ball.set_collision_layer_value(2, false)
		ball.player_with_ball = null
		if body is RigidBody2D:
			if last_player_touch_ball.own_team == 0:
				current_restarting_state = RestartingState.GOAL_KICK_1
				current_team_posesion = 1
			else:
				current_restarting_state = RestartingState.CORNER_KICK_R_0
				current_team_posesion = 0
		current_match_state = MatchState.STOP_GAME
		match_state_changed.emit()
		process_match_states()


func _on_down_l_body_entered(body: Node2D) -> void:
	if current_match_state == MatchState.IN_GAME:
		$SFX/Whistle.play()
		ball.set_collision_layer_value(2, false)
		ball.player_with_ball = null
		if body is RigidBody2D:
			if last_player_touch_ball.own_team == 0:
				current_restarting_state = RestartingState.CORNER_KICK_L_1
				current_team_posesion = 1
			else:
				current_restarting_state = RestartingState.GOAL_KICK_0
				current_team_posesion = 0
		current_match_state = MatchState.STOP_GAME
		match_state_changed.emit()
		process_match_states()


func _on_down_r_body_entered(body: Node2D) -> void:
	if current_match_state == MatchState.IN_GAME:
		$SFX/Whistle.play()
		ball.set_collision_layer_value(2, false)
		ball.player_with_ball = null
		if body is RigidBody2D:
			if last_player_touch_ball.own_team == 0:
				current_restarting_state = RestartingState.CORNER_KICK_R_1
				current_team_posesion = 1
			else:
				current_restarting_state = RestartingState.GOAL_KICK_0
				current_team_posesion = 0
		current_match_state = MatchState.STOP_GAME
		match_state_changed.emit()
		process_match_states()


func _on_players_in_camera_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.own_team == 0:
			players_in_camera.append(area)



func _on_players_in_camera_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.own_team == 0:
			players_in_camera.erase(area)


func _on_pass_area_area_entered(area):
	if area.own_team == 0 and ball.player_with_ball != area:
		$Players/Team0.in_pass_area.append(area)



func _on_pass_area_area_exited(area):
	$Players/Team0.in_pass_area.erase(area)


func _on_palo_sound_body_entered(body: Node2D) -> void:
	if body.is_in_group("palos"):
		palo.play()
	


func _on_restarting_timer_timeout() -> void:
	if current_match_state == MatchState.RESTARTING:
		current_match_state = MatchState.IN_GAME
	$RestartingTimer.stop()
	
