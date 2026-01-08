extends Area2D


#Variables externas
@export var user_player_speed : float = 40.0
@export var cpu_player_speed : float = 35.0
@export var time_decision : float = 1.0



@export var static_position : bool = false
@export var own_team : int = 0
@export var pass_power : float = 75.0
@export var shot_power : float = 120.0
@export var sweeper : bool = false
var field_player : bool = true
var option_pass : Array[Area2D]


var in_shot_area : bool = false
var can_move : bool = true
var move : bool = false
var direction : Vector2
var user_controlled : bool = false
var velocity : Vector2

var distance_to_target_general : float

var can_throw_in : bool = true

enum PlayerState {
	GO_TO_POSITION,
	GO_TO_BALL_ATTACK,
	GO_TO_BALL_DEFENSE,
	WITH_BALL,
	RECEIVER,
	NOT_AVAILABLE,
	GO_TO_CELEBRATION,
	USER_CONTROLLED,
	GO_TO_KICKOFF_POSITION,
	RESTARTER,
	RESTARTER_THROW_IN,
	GO_TO_KICKOFF_POSITION_RESTARTER_1,
	GO_TO_KICKOFF_POSITION_RESTARTER_2,
	GO_TO_CORNER_POSITION,
}

enum PlayerWithBall {
	GO_TO_ATTACK_POSITION,
	PASS,
	SHOT,
}

var current_player_state : PlayerState = PlayerState.GO_TO_KICKOFF_POSITION
var current_player_with_ball : PlayerWithBall =  PlayerWithBall.GO_TO_ATTACK_POSITION
var target : Vector2
var pass_target : Vector2
var at_target : bool = false

# Verificar si está en Firs Time Finish Zone
var in_ftfc : bool = false
var in_ftfl : bool = false
var in_ftfr : bool = false

var in_input_buffer_zone : bool = false

@onready var dinamic_position = get_node("Positions/Position")
@onready var default_position = get_node("Positions/Position").global_position
var kick_off_position : Vector2
@onready var ball = get_tree().get_first_node_in_group("ball")
@onready var Match = get_tree().get_first_node_in_group("match")
#@onready var left_controls = get_tree().get_first_node_in_group("left_controls")
@onready var left_controls = get_tree().get_first_node_in_group("stick")
@onready var defense_points = get_tree().get_nodes_in_group("defense_points")
@onready var goals = get_tree().get_nodes_in_group("goal")
@onready var foot: Marker2D = $Foot
@onready var own_goal : Node2D = get_parent().own_goal
@onready var players_team_0 = get_tree().get_nodes_in_group("player_team_0")



func _ready() -> void:
	kick_off_position = global_position
	set_option_pass()
	$Label.text = name
	own_team = get_parent().team
	#$Sprite2D.modulate = get_parent().shirt_color
	#Match.match_state_changed.connect(_on_match_state_changed)
	call_deferred("behavior_tree")
	call_deferred("set_initial_kick_off")
	call_deferred("signals_connect")
	await get_tree().create_timer(0.1).timeout
	call_deferred("set_shirt_palette")
	call_deferred("set_player_level") # mejorar esto

func signals_connect():
	Match.match_state_changed.connect(_on_match_state_changed)
	goals[0].Goal.connect(_on_goal_scored)
	goals[1].Goal.connect(_on_goal_scored)
	#get_tree().get_first_node_in_group("right_controls").shoot_pressed.connect(_on_shot_button_pressed)


func set_initial_kick_off():
	if Match.current_team_posesion == own_team:
		if get_parent().restarter1 == self:
			global_position = Match.restarter_point_1.global_position
			look_at(ball.global_position)
		elif get_parent().restarter2 == self:
			global_position = Match.restarter_point_2.global_position	
			look_at(ball.global_position)


func set_shirt_palette():
	var mat = $AnimatedSprite2D.material.duplicate()
	$AnimatedSprite2D.material = mat
	$AnimatedSprite2D.material.set_shader_parameter("palette_to", get_parent().team_palette)


func set_player_level():
	user_player_speed = get_parent().user_player_speed
	cpu_player_speed = get_parent().cpu_player_speed
	time_decision = get_parent().time_decision 
	#if own_team == 0 and Match.touch_gamepad:
		#user_player_speed *= 1.4
		#shot_power *= 1.4

func _physics_process(delta):
	$Label.text = str(current_player_state)
	distance_to_target_general = global_position.distance_to(target)
	if current_player_state == PlayerState.GO_TO_POSITION:
		if distance_to_target_general < 3:
				#move = false
			at_target = true
		else:
			at_target = false
	#if name == "FieldPlayer8" and own_team == 0:
		#if at_target:
			#print("LLegué a destino")
		#print("Animación actual: ", $AnimatedSprite2D.animation)
		#print("Global position: ", global_position)
		#print("Target: ", target)
		#print("Distancia: ", distance_to_target_general)
		#if current_player_state == PlayerState.GO_TO_POSITION:
			#if distance_to_target_general < 5:
				##move = false
				#at_target = true
			#else:
				#at_target = false
	$Node/ShadowPlayer.global_position = Vector2(global_position.x + 2, global_position.y)
	update_behavior_tree(delta)
	
	
func set_option_pass():
	match name:
		"FieldPlayer1":
			option_pass.append(get_parent().get_node("FieldPlayer4"))
			option_pass.append(get_parent().get_node("FieldPlayer5"))
			option_pass.append(get_parent().get_node("FieldPlayer8"))
		"FieldPlayer2":
			option_pass.append(get_parent().get_node("FieldPlayer4"))
			option_pass.append(get_parent().get_node("FieldPlayer7"))
			option_pass.append(get_parent().get_node("FieldPlayer5"))
		"FieldPlayer3":
			option_pass.append(get_parent().get_node("FieldPlayer5"))
			option_pass.append(get_parent().get_node("FieldPlayer7"))
			option_pass.append(get_parent().get_node("FieldPlayer10"))
		"FieldPlayer4":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
		"FieldPlayer5":
			option_pass.append(get_parent().get_node("FieldPlayer4"))
			option_pass.append(get_parent().get_node("FieldPlayer7"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
		"FieldPlayer6":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
			option_pass.append(get_parent().get_node("FieldPlayer10"))
		"FieldPlayer7":
			option_pass.append(get_parent().get_node("FieldPlayer10"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
		"FieldPlayer8":
			option_pass.append(get_parent().get_node("FieldPlayer10"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
		"FieldPlayer9":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
			option_pass.append(get_parent().get_node("FieldPlayer10"))
		"FieldPlayer10":
			option_pass.append(get_parent().get_node("FieldPlayer8"))
			option_pass.append(get_parent().get_node("FieldPlayer6"))
			option_pass.append(get_parent().get_node("FieldPlayer9"))
	

func search_nearest_defense_point() -> Vector2:
	var min_distance : float = global_position.distance_squared_to(ball.global_position)
	var min_point : Vector2 = ball.global_position
	for point in defense_points:
		var distance = global_position.distance_squared_to(point.global_position)
		if distance < min_distance:
			min_distance = distance
			min_point = point.global_position
	return min_point

func update_behavior_tree(delta):
	if own_team == 0:
		if current_player_state == PlayerState.WITH_BALL and \
			current_player_with_ball == PlayerWithBall.GO_TO_ATTACK_POSITION and \
			ball.global_position.y <= Match.limit_line * get_parent().team_multip and \
			in_shot_area == false:
				current_player_with_ball = PlayerWithBall.PASS
				behavior_tree()
				return
	else:
		if current_player_state == PlayerState.WITH_BALL and \
			current_player_with_ball == PlayerWithBall.GO_TO_ATTACK_POSITION and \
			ball.global_position.y >= Match.limit_line * get_parent().team_multip and \
			in_shot_area == false:
				current_player_with_ball = PlayerWithBall.PASS
				behavior_tree()
				return
		
	match Match.current_match_state:
		Match.MatchState.IN_GAME:
			match current_player_state:
				PlayerState.GO_TO_POSITION:
					if at_target:
						move = false
						$AnimatedSprite2D.play("idle")
					else:
						move = true
						$AnimatedSprite2D.play("run")
				PlayerState.GO_TO_BALL_ATTACK:
						#if distance_to_target_general > 2:
						at_target = false
						move = true
						if ball.ball_in_hand == false:
							if Match.current_team_posesion == own_team:
								if ball.player_with_ball != null:
									current_player_state = PlayerState.GO_TO_POSITION
									behavior_tree()
							else:
								target = ball.global_position
								#look_at(ball.global_position)
								move_animations()
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							behavior_tree()
				PlayerState.RECEIVER:
					if check_ftf():
						$Node/PivotIBA.global_position = global_position
						$Node/PivotIBA.look_at(ball.global_position)
						$Node/PivotIBA/InputBufferArea/Sprite2D.visible = true
					else:
						$Node/PivotIBA/InputBufferArea/Sprite2D.visible = false
				PlayerState.GO_TO_BALL_DEFENSE:
						if Match.current_team_posesion == own_team:
							if ball.player_with_ball != self:
								current_player_state = PlayerState.GO_TO_POSITION
								behavior_tree()
						else:
							if ball.ball_in_hand == false:
								#target = search_nearest_defense_point()
								target = ball.global_position
								#look_at(ball.global_position) #este estaba activado
								#move_animations()
							else:
								current_player_state = PlayerState.GO_TO_POSITION
								#behavior_tree()
				#PlayerState.GO_TO_POSITION:
					#if sweeper:
						#target = own_goal.sweeper_position.global_position
						#look_at(ball.global_position)
						##move = true

				PlayerState.USER_CONTROLLED:
					at_target = false
					move = true
					if ball.player_with_ball == self:
						if Input.is_action_just_released("shot"):
							if direction.length() > 0.01:
								shot_user_controlled(direction)
								#shot(choice_target_shot(get_parent().rival_goal))
							else:
								var angle = rotation
								var direction2 = Vector2.RIGHT.rotated(angle)
								shot_user_controlled(direction2)
						elif Input.is_action_just_released("pass"):
							if direction.length() > 0.01:
								if get_parent().in_pass_area.size() > 0:
									Match.receiver = get_parent().in_pass_area.pick_random()
									
									pass_ball_user_controlled(Match.receiver)
									#shot(choice_target_shot(get_parent().rival_goal))
								else:
									shot_user_controlled(direction)
							else:
								var angle = rotation
								var direction2 = Vector2.RIGHT.rotated(angle)
								shot_user_controlled(direction2)
					else:
						if in_input_buffer_zone:
							if Input.is_action_just_released("shot"):
								Match.current_input_buffer_action = Match.InputBufferActions.SHOOT
							elif Input.is_action_just_released("pass"):
								Match.current_input_buffer_action = Match.InputBufferActions.PASS
						else:
							if Input.is_action_just_released("pass"):
								#print("Cambiar de jugador")
								user_controlled = false
								Match.player_controlled	= get_player_controlled()
								if Match.player_controlled:
									Match.player_controlled.current_player_state = PlayerState.USER_CONTROLLED
									Match.player_controlled.user_controlled = true
								#else:
									#print("ningún jugador controlado")
								#print("Ahora el jugador controlado es: ", Match.player_controlled.name)
								
								current_player_state = PlayerState.GO_TO_POSITION
								behavior_tree()
					
		#Match.MatchState.POSITIONING:
			#if current_player_state == PlayerState.RESTARTER:
				#look_at(ball.global_position)			
		Match.MatchState.POSITIONING:
			if current_player_state == PlayerState.RESTARTER:
				if distance_to_target_general < 3:
					at_target = true
				else:
					at_target = false
			if at_target:
				move = false
				$AnimatedSprite2D.play("idle")
			else:
				move = true
			move_animations()
		Match.MatchState.RESTARTING:
			match current_player_state:
				PlayerState.GO_TO_BALL_ATTACK:
						target = ball.global_position
						#look_at(target) # este estaba activado
						if distance_to_target_general < 1:
							at_target = true
						else:
							at_target = false	
						if at_target:
							move = false
							$AnimatedSprite2D.play("idle")
						else:
							move = true
							
						move_animations()		
		Match.MatchState.STOP_GAME:
				match current_player_state:
					PlayerState.GO_TO_CELEBRATION:
						#var rival_gk
						#match own_team:
							#0:
								#rival_gk = Match.gk_1
							#_:
								#rival_gk = Match.gk_0
						if Match.goal_scorer != self:
							target = Match.goal_scorer.global_position
							move = true
							can_move = true
							look_at(target)
							
						#await get_tree().create_timer(5.0).timeout
						#can_move = false
						#target = global_position
						
					_:
						target = global_position
						at_target = true
						$AnimatedSprite2D.play("idle")
						
	
	#if Match.current_match_state == Match.MatchState.IN_GAME:
		#if distance_to_target_general < 5:
			#behavior_tree()

	# Prueba a ver si no rompo nada
	if move and can_move:
		movement(delta)
		
		if Match.current_match_state == Match.MatchState.RESTARTING:
			if direction.length() > 0.1:
				pass
				#$AnimatedSprite2D.play("run")
			else:
				pass
				#$AnimatedSprite2D.play("idle")
		elif Match.current_match_state == Match.MatchState.POSITIONING:
			if velocity.length() > 0.1:
				pass
				#$AnimatedSprite2D.play("run")
			else:
				pass
				#$AnimatedSprite2D.play("idle")
		else:
			if current_player_state != PlayerState.GO_TO_CELEBRATION:
				if direction.length() > 0.1:
					pass
					#$AnimatedSprite2D.play("run")
				else:
					pass
					#$AnimatedSprite2D.play("idle")
					if user_controlled:
						ball.get_node("AnimationPlayer").play("RESET")
						#ball.get_node("AnimatedSprite2D").play("h0")
					#else:
						#ball.get_node("AnimatedSprite2D").play("h0free")			
	elif move == false and can_move:
		#$AnimatedSprite2D.play("idle")
		pass


func move_animations_user_controlled():
	if velocity == Vector2.ZERO and ball.player_with_ball == self:
		$AnimatedSprite2D.play("pass")
		ball.get_node("AnimatedSprite2D").play("h0")
	else:
		if can_move:
			if velocity == Vector2.ZERO:
				$AnimatedSprite2D.play("idle")
			else:
				$AnimatedSprite2D.play("run")
				ball.get_node("AnimatedSprite2D").play("h0free")

func move_animations():
	#if distance_to_target_general < 5:
		#$AnimatedSprite2D.play("idle")
		#look_at(ball.global_position)
	#else:
		#$AnimatedSprite2D.play("run")
		#look_at(target)
	
	if can_move:
		if move:
			if current_player_state != PlayerState.GO_TO_CELEBRATION:
				$AnimatedSprite2D.play("run")
				if can_throw_in == true:
					look_at(target)
		else:
			if current_player_state != PlayerState.WITH_BALL or \
				current_player_state != PlayerState.NOT_AVAILABLE or \
				current_player_state != PlayerState.RESTARTER_THROW_IN:
					$AnimatedSprite2D.play("idle")
					look_at(ball.global_position)
	else:
		if can_throw_in == false:
			look_at(Match.receiver.global_position)

	#else:
		#if current_player_state != PlayerState.WITH_BALL or \
			##current_player_with_ball != PlayerWithBall.PASS or \
				#current_player_state != PlayerState.NOT_AVAILABLE or \
				#current_player_state != PlayerState.RESTARTER_THROW_IN:
					#$AnimatedSprite2D.play("idle")
					#look_at(ball.global_position)
				

func behavior_tree():
	
	match Match.current_match_state:
		Match.MatchState.STOP_GAME:
			match current_player_state:
				PlayerState.GO_TO_CELEBRATION:
					var rival_gk
					match own_team:
						0:
							rival_gk = Match.gk_1
						_:
							rival_gk = Match.gk_0
					
					
					if rival_gk.shooter:
						Match.goal_scorer = rival_gk.shooter
					else:
						if Match.last_player_touch_ball.own_team != rival_gk.own_team:
							Match.goal_scorer = Match.last_player_touch_ball
						else:
							Match.goal_scorer = get_parent().get_node("FieldPlayer9")
					
					if Match.goal_scorer_position.x > 0:
						if Match.goal_scorer == self:
							target = get_parent().celebration_l.global_position	
					else:
						if Match.goal_scorer == self:
							target = get_parent().celebration_r.global_position

					if Match.goal_scorer == self:
						$AnimatedSprite2D.play("goal_scorer")
					else:
						$AnimatedSprite2D.play("goal_no_scorer")
					move = true
					can_move = true		

			
				_:
					target = global_position
					#current_player_state = PlayerState.GO_TO_POSITION
		Match.MatchState.POSITIONING:
			can_move = true
			#move = true
			$DefenseZone.set_collision_mask_value(8, false)
			match Match.current_restarting_state:
				Match.RestartingState.KICK_OFF:
					if Match.current_team_posesion == own_team:
						if get_parent().restarter1 == self:
							current_player_state = PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_1
						elif get_parent().restarter2 == self:
							current_player_state = PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_2
							
						else:
							current_player_state = PlayerState.GO_TO_KICKOFF_POSITION
					else:
						current_player_state = PlayerState.GO_TO_KICKOFF_POSITION

				Match.RestartingState.GOAL_KICK_0:
					if own_team == 0:
						if get_parent().restarter_goal_kick == self:
							target = Match.goal_kick_point_0.global_position
							current_player_state = PlayerState.RESTARTER	
						else:
							current_player_state = PlayerState.GO_TO_POSITION
					else:
						current_player_state = PlayerState.GO_TO_POSITION
				Match.RestartingState.GOAL_KICK_1:
					if own_team == 1:
						if get_parent().restarter_goal_kick == self:
							target = Match.goal_kick_point_1.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
					else:
						current_player_state = PlayerState.GO_TO_POSITION
				Match.RestartingState.CORNER_KICK_L_0:
					if own_team == 0:
						if get_parent().restarter_corner == self:
							target = Match.corner_kick_l_0.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							get_parent().corner_position()
							#move = true
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						get_parent().set_corner_defenders()
				Match.RestartingState.CORNER_KICK_R_0:
					if own_team == 0:
						if get_parent().restarter_corner == self:
							target = Match.corner_kick_r_0.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							get_parent().corner_position()
							#can_move = true
							#move = true
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						get_parent().set_corner_defenders()
						#behavior_tree()
				Match.RestartingState.CORNER_KICK_L_1:
					if own_team == 1:
						if get_parent().restarter_corner == self:
							target = Match.corner_kick_l_1.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							get_parent().corner_position()
							#can_move = true
							#move = true
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						get_parent().set_corner_defenders()
						#behavior_tree()
				Match.RestartingState.CORNER_KICK_R_1:
					if own_team == 1:
						if get_parent().restarter_corner == self:
							target = Match.corner_kick_r_1.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							get_parent().corner_position()
							#if name == "FieldPlayer8":
								#print("Dentro de jugador")
								#print(target)
								#
								##can_move = true
								#move = true
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						get_parent().set_corner_defenders()					
				Match.RestartingState.THROW_IN_L_0:
					if own_team == 0:
						if get_parent().restarter_throw_in == self:
						#if get_parent().restarter_throw_in_l == self:
							set_collision_mask_value(2,false)
							target = Match.throw_in_l.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							#behavior_tree()
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						#behavior_tree()
				Match.RestartingState.THROW_IN_R_0:
					if own_team == 0:
						if get_parent().restarter_throw_in == self:
						#if get_parent().restarter_throw_in_r == self:
							set_collision_mask_value(2,false)
							target = Match.throw_in_r.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							#behavior_tree()
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						#behavior_tree()
				Match.RestartingState.THROW_IN_L_1:
					if own_team == 1:
						if get_parent().restarter_throw_in == self:
						#if get_parent().restarter_throw_in_l == self:
							set_collision_mask_value(2,false)
							target = Match.throw_in_r.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							#behavior_tree()
					else:
						current_player_state = PlayerState.GO_TO_POSITION
						#behavior_tree()
				Match.RestartingState.THROW_IN_R_1:
					if own_team == 1:
						if get_parent().restarter_throw_in == self:
						#if get_parent().restarter_throw_in_r == self:
							set_collision_mask_value(2,false)
							target = Match.throw_in_l.global_position
							current_player_state = PlayerState.RESTARTER
						else:
							current_player_state = PlayerState.GO_TO_POSITION
							#behavior_tree()
					else:
						current_player_state = PlayerState.GO_TO_POSITION
			#move = true
			#move_animations() # ESTABA ACTIVADO ACA
			match current_player_state:
				PlayerState.GO_TO_POSITION:
					#go_to_position()
					target = default_position
				PlayerState.GO_TO_KICKOFF_POSITION:
					global_position = kick_off_position	
					target = global_position
				PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_1:
					global_position = Match.restarter_point_1.global_position
					target = global_position
					#look_at(ball.global_position)
				PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_2:
					global_position = Match.restarter_point_2.global_position
					target = global_position
					#look_at(ball.global_position)
			#can_move = true
		Match.MatchState.RESTARTING:
			look_at(ball.global_position)
			match Match.current_restarting_state:
				Match.RestartingState.KICK_OFF:
					#if Match.current_team_posesion == own_team:
						#if get_parent().restarter1 == self:
							#current_player_state = PlayerState.GO_TO_BALL_ATTACK
							##target = Match.restarter_point_1.global_position
							#look_at(ball.global_position)
						#elif get_parent().restarter2 == self:
							#target = global_position	
							#look_at(ball.global_position)
						#else: 
							#target = kick_off_position
							#$DefenseZone.set_collision_mask_value(8, true)
					#else:
						#target = kick_off_position
						#$DefenseZone.set_collision_mask_value(8, true)
					#await get_tree().create_timer(1.0).timeout
					#set_collision_mask_value(2, true)
					if Match.current_team_posesion == own_team:
						if get_parent().restarter1 == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.GOAL_KICK_0:
					if own_team == 0:
						if get_parent().restarter_goal_kick == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.GOAL_KICK_1:
					if own_team == 1:
						if get_parent().restarter_goal_kick == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.CORNER_KICK_L_0:
					if own_team == 0:
						if get_parent().restarter_corner == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.CORNER_KICK_R_0:
					if own_team == 0:
						if get_parent().restarter_corner == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.CORNER_KICK_L_1:
					if own_team == 1:
						if get_parent().restarter_corner == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.CORNER_KICK_R_1:
					if own_team == 1:
						if get_parent().restarter_corner == self:
							current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.THROW_IN_L_0: 
					if own_team == 0:
						#if get_parent().restarter_throw_in_l == self:
						if get_parent().restarter_throw_in == self:
							choice_reveicer()
							if can_throw_in:
								can_throw_in = false
								ball.player_with_ball = self
								current_player_state = PlayerState.RESTARTER_THROW_IN
								throw_in(Match.receiver)
							#current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.THROW_IN_R_0:
					if own_team == 0:
						#if get_parent().restarter_throw_in_r == self:
						if get_parent().restarter_throw_in == self:
							choice_reveicer()
							if can_throw_in:
								can_throw_in = false
								current_player_state = PlayerState.RESTARTER_THROW_IN
								ball.player_with_ball = self
								throw_in(Match.receiver)
							#current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.THROW_IN_L_1:
					if own_team == 1:
						#if get_parent().restarter_throw_in_l == self:
						if get_parent().restarter_throw_in == self:
							choice_reveicer()
							if can_throw_in:
								can_throw_in = false
								current_player_state = PlayerState.RESTARTER_THROW_IN
								ball.player_with_ball = self
								throw_in(Match.receiver)
							#current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
				Match.RestartingState.THROW_IN_R_1:
					if own_team == 1:
						#if get_parent().restarter_throw_in_r == self:
						if get_parent().restarter_throw_in == self:
							choice_reveicer()
							if can_throw_in:
								can_throw_in = false
								current_player_state = PlayerState.RESTARTER_THROW_IN
								ball.player_with_ball = self
								throw_in(Match.receiver)
							#current_player_state = PlayerState.GO_TO_BALL_ATTACK
							#behavior_tree()
						#else:
							#target = global_position
					#else:
						#target = global_position
		Match.MatchState.IN_GAME:
			if can_throw_in:
				$DefenseZone.set_collision_mask_value(8, true)
			if user_controlled == true:
				if current_player_state != PlayerState.NOT_AVAILABLE:
					current_player_state = PlayerState.USER_CONTROLLED
					move = true
					can_move = true
			match current_player_state:
				PlayerState.GO_TO_KICKOFF_POSITION_RESTARTER_2:
					if own_team == 0 and Match.current_game_mode == Match.GameMode.PLAYER_VS_CPU:
						current_player_state = PlayerState.GO_TO_POSITION
						behavior_tree()
				PlayerState.GO_TO_KICKOFF_POSITION:
					current_player_state = PlayerState.GO_TO_POSITION
					behavior_tree()
				PlayerState.GO_TO_POSITION:
					go_to_position()
					#if Match.current_team_posesion == own_team:
						#if !static_position:
							#if own_team == 0:
								#if ball.global_position.y <= get_parent().attack_line:
									#dinamic_position.global_position.y = default_position.y - (40 * get_parent().team_multip)
								#elif ball.global_position.y > get_parent().attack_line and ball.global_position.y < get_parent().defend_line:
									#dinamic_position.global_position = default_position
								#else:
									#dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
							#else:
								#if ball.global_position.y >= get_parent().attack_line:
									#dinamic_position.global_position.y = default_position.y - (40 * get_parent().team_multip)
								#elif ball.global_position.y < get_parent().attack_line and ball.global_position.y > get_parent().defend_line:
									#dinamic_position.global_position = default_position
								#else:
									#dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
							#dinamic_position.global_position = set_nearest_position(dinamic_position.global_position)
							#dinamic_position_corrected(dinamic_position.global_position)		
					#else:
						#if !static_position:
							#if own_team == 0:
								#if ball.global_position.y >= Match.limit_line * get_parent().team_multip:
									#dinamic_position.global_position.y = default_position.y + (70 * get_parent().team_multip)
								#elif ball.global_position.y >= get_parent().defend_line and ball.global_position.y <= get_parent().attack_line:
									#dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
								#else:
									#dinamic_position.global_position = default_position
							#else:
								#if ball.global_position.y <= Match.limit_line * get_parent().team_multip:
									#dinamic_position.global_position.y = default_position.y + (70 * get_parent().team_multip)
								#elif ball.global_position.y <= get_parent().defend_line and ball.global_position.y >= get_parent().attack_line:
									#dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
								#else:
									#dinamic_position.global_position = default_position
					#target = dinamic_position.global_position
					#look_at(target)
				PlayerState.RECEIVER:
					target = global_position
				PlayerState.WITH_BALL:
					randomize()
					if in_shot_area:
						if current_player_with_ball != PlayerWithBall.SHOT:
							current_player_with_ball = PlayerWithBall.SHOT
							behavior_tree()
							return	
					var rand_time_decision : float = randf_range(0.2, time_decision)
					$TimerDecision.wait_time = rand_time_decision
					$TimerDecision.start()
					match current_player_with_ball:
						PlayerWithBall.GO_TO_ATTACK_POSITION:
							target = Vector2(default_position.x, -195 * get_parent().team_multip)
						PlayerWithBall.SHOT:
							$TimerDecision.stop()
							shot(choice_target_shot(get_parent().rival_goal))
							#shot(choice_away_target_shot(get_parent().rival_goal))
						PlayerWithBall.PASS:
							$TimerDecision.stop()
							#var temporal_option_pass = option_pass.duplicate(true)
							#if temporal_option_pass.size() > 0:
								#if temporal_option_pass[0].current_player_state == PlayerState.NOT_AVAILABLE:
										#temporal_option_pass.erase(temporal_option_pass[0])
							#if temporal_option_pass.size() > 1:
								#if temporal_option_pass[1].current_player_state == PlayerState.NOT_AVAILABLE:
										#temporal_option_pass.erase(temporal_option_pass[1])
							#if temporal_option_pass.size() > 2:
								#if temporal_option_pass[2].current_player_state == PlayerState.NOT_AVAILABLE:
										#temporal_option_pass.erase(temporal_option_pass[2])
							#Match.receiver = temporal_option_pass.pick_random()
							choice_reveicer()
							pass_ball(Match.receiver)
				PlayerState.NOT_AVAILABLE:
					can_move = false
					$AnimatedSprite2D.play("fall")
					if user_controlled == true:
						user_controlled = false
						Match.player_controlled	= get_player_controlled()
						if Match.player_controlled:
							Match.player_controlled.current_player_state = PlayerState.USER_CONTROLLED
							Match.player_controlled.user_controlled = true
						#else:
							#"Ningún jugador controlado"
						#Match.player_controlled.behavior_tree()
					else:
						if Match.player_controlled == self:
							print("Esto está mal")
					set_collision_mask_value(2, false)
					target = global_position
					await get_tree().create_timer(2.0).timeout
					set_collision_mask_value(2, true)
					current_player_state = PlayerState.GO_TO_POSITION
					can_move = true
					behavior_tree()
				PlayerState.RESTARTER_THROW_IN:
					await get_tree().create_timer(3.0).timeout
					set_collision_mask_value(2, true)
					current_player_state = PlayerState.GO_TO_POSITION
					can_move = true
					behavior_tree()
	move_animations() #Acá lo puse ahora
	var distance_to_target : float = global_position.distance_to(target)
	if distance_to_target > 5:
		move = true
		if current_player_state != PlayerState.USER_CONTROLLED:
			at_target = false
		if move and can_move:
			look_at(target)
	else:
		if current_player_state != PlayerState.USER_CONTROLLED:
			move = false
			at_target = true
			#if $AnimatedSprite2D.animation == "throw_in":
				#await get_tree().create_timer(1.0).timeout
				#$AnimatedSprite2D.play("idle")
			#else:
				#$AnimatedSprite2D.play("idle")
		if !move and can_move:
			look_at(ball.global_position)
	
func get_player_controlled() -> Area2D:
	var available_camera_players : Array[Area2D]
	var available_players : Array[Area2D]
	#var choiced_player : Area2D
	
	if Match.players_in_camera.size() > 0:
		for player in Match.players_in_camera:
			if player.current_player_state != PlayerState.NOT_AVAILABLE and player.user_controlled == false:
				available_camera_players.append(player)
		return available_camera_players.pick_random()
	else:
		for player in players_team_0:
			if player.current_player_state != PlayerState.NOT_AVAILABLE:
				available_players.append(player)
		return available_players.pick_random()
	
	#for player in available_players:
		#var distance = player.global_position.distance_to(ball.global_position)
		#if distance < 50:
			#choiced_player = player
			#return player
	#
	#if choiced_player == null:
		#return available_players.pick_random()
	#else:
		#return choiced_player

		 

func throw_in(receiver):
	Match.current_match_state = Match.MatchState.IN_GAME
	Match.process_match_states()
	can_move = false
	look_at(receiver.global_position)
	pass_target = receiver.global_position
	receiver.current_player_state = PlayerState.RECEIVER
	#set_collision_mask_value(2, false)
	if ball.player_with_ball == self:
		ball.player_with_ball = null
		$DefenseZone.set_collision_mask_value(8, false)
		var dir = ball.global_position.direction_to(pass_target)
		dir = dir.normalized()
		var impulse = dir * pass_power
		#if Match.current_match_state != Match.MatchState.IN_GAME:
		#Match.current_match_state = Match.MatchState.IN_GAME
		#Match.process_match_states()
		#current_player_state = PlayerState.GO_TO_POSITION
		Match.match_state_changed.emit()
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("throw_in")
		await get_tree().create_timer(0.1).timeout
		ball.apply_central_impulse(impulse)
		#print("Destino de pase: ", receiver.global_position)
		#print("Pasador: ", self.name)
		#print("Receptor: ", receiver.name)
		#print("-------")
		#await get_tree().create_timer(0.3).timeout
		#current_player_state = PlayerState.GO_TO_POSITION
		var distance = global_position.distance_to(pass_target)
		ball.set_ball_height(distance, pass_power)
		await get_tree().create_timer(0.1).timeout
		set_collision_mask_value(2, true)
		for player in get_tree().get_nodes_in_group("player"):
			player.get_node("DefenseZone").set_collision_mask_value(8, true)
		await get_tree().create_timer(0.2).timeout
		can_move = true
		move_animations()
		await get_tree().create_timer(1.0).timeout
		can_throw_in = true




func choice_reveicer():
	var temporal_option_pass = option_pass.duplicate(true)
	if temporal_option_pass.size() > 0:
		if temporal_option_pass[0].current_player_state == PlayerState.NOT_AVAILABLE:
				temporal_option_pass.erase(temporal_option_pass[0])
	if temporal_option_pass.size() > 1:
		if temporal_option_pass[1].current_player_state == PlayerState.NOT_AVAILABLE:
				temporal_option_pass.erase(temporal_option_pass[1])
	if temporal_option_pass.size() > 2:
		if temporal_option_pass[2].current_player_state == PlayerState.NOT_AVAILABLE:
				temporal_option_pass.erase(temporal_option_pass[2])
	Match.receiver = temporal_option_pass.pick_random()


func go_to_position():
	if Match.current_team_posesion == own_team:
		if !static_position:
			if own_team == 0:
				if ball.global_position.y <= get_parent().attack_line:
					dinamic_position.global_position.y = default_position.y - (40 * get_parent().team_multip)
				elif ball.global_position.y > get_parent().attack_line and ball.global_position.y < get_parent().defend_line:
					dinamic_position.global_position = default_position
				else:
					dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
			else:
				if ball.global_position.y >= get_parent().attack_line:
					dinamic_position.global_position.y = default_position.y - (40 * get_parent().team_multip)
				elif ball.global_position.y < get_parent().attack_line and ball.global_position.y > get_parent().defend_line:
					dinamic_position.global_position = default_position
				else:
					dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
			dinamic_position.global_position = set_nearest_position(dinamic_position.global_position)
			dinamic_position_corrected(dinamic_position.global_position)		
	else:
		if !static_position:
			if own_team == 0:
				if ball.global_position.y >= Match.limit_line * get_parent().team_multip:
					dinamic_position.global_position.y = default_position.y + (70 * get_parent().team_multip)
				elif ball.global_position.y >= get_parent().defend_line and ball.global_position.y <= get_parent().attack_line:
					dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
				else:
					dinamic_position.global_position = default_position
			else:
				if ball.global_position.y <= Match.limit_line * get_parent().team_multip:
					dinamic_position.global_position.y = default_position.y + (70 * get_parent().team_multip)
				elif ball.global_position.y <= get_parent().defend_line and ball.global_position.y >= get_parent().attack_line:
					dinamic_position.global_position.y = default_position.y + (40 * get_parent().team_multip)
				else:
					dinamic_position.global_position = default_position
	target = dinamic_position.global_position
	look_at(target)			
	
		
func dinamic_position_corrected(position_to_correct):
	if position_to_correct.x > Match.GAME_FIELD_MARGIN.x:
		dinamic_position.global_position.x = Match.GAME_FIELD_MARGIN.x
	if position_to_correct.x < -Match.GAME_FIELD_MARGIN.x:
		dinamic_position.global_position.x = -Match.GAME_FIELD_MARGIN.x
	if position_to_correct.y > Match.GAME_FIELD_MARGIN.y:
		dinamic_position.global_position.y = Match.GAME_FIELD_MARGIN.y
	if position_to_correct.y < -Match.GAME_FIELD_MARGIN.y:
		dinamic_position.global_position.y = -Match.GAME_FIELD_MARGIN.y

func movement(delta):
	if current_player_state != PlayerState.USER_CONTROLLED: 
		direction = global_position.direction_to(target)
		direction = direction.normalized()
	else:
		direction = Vector2.ZERO
		if Match.touch_gamepad == false:
			if Input.is_action_pressed("ui_up") or left_controls.direction.y < -0.1:
				direction.y -= 1
				#rotation = -90.0
			if Input.is_action_pressed("ui_down") or left_controls.direction.y > 0.1:
				direction.y += 1
				#rotation = 90.0
			if Input.is_action_pressed("ui_right") or left_controls.direction.x > 0.1:
				direction.x += 1
				#rotation = 0.0
			if Input.is_action_pressed("ui_left") or left_controls.direction.x < - 0.1:
				direction.x -= 1
				#rotation = 180.0
			move_animations_user_controlled()
		else:
			direction = left_controls.direction
			direction = direction.normalized()
			direction *= 1.25
			move_animations_user_controlled()
		
		if can_move:
			look_at(global_position + direction)
		
	var speed : float
	if own_team == 0:
		speed = user_player_speed
	else:
		speed = cpu_player_speed
	#var velocity = direction * speed * delta
	
	velocity = direction * speed * delta
	global_position += velocity

	# PRUEBO DESACTIVAR ESTO
	#if can_move:
		##look_at(global_position + direction) #No recuerdo por qué estaba esto
		#if current_player_state != PlayerState.GO_TO_CELEBRATION:
			#if move:
				#$AnimatedSprite2D.play("run")
		#else:
			#if move:
				#$AnimatedSprite2D.play("goal_no_scorer")
		#ball.get_node("AnimationPlayer").play("at_foot")

func pass_ball_user_controlled(receiver : Area2D):
	Match.get_node("CanvasLayer/DevLabels/DevLabel3").text = str(receiver.check_ftf())
	can_move = false
	look_at(receiver.global_position)
	pass_target = receiver.global_position
	receiver.current_player_state = PlayerState.RECEIVER
	receiver.behavior_tree()
	if ball.player_with_ball == self:
		ball.player_with_ball = null
		set_collision_mask_value(2, false)
		$DefenseZone.set_collision_mask_value(8, false)
		var dir = ball.global_position.direction_to(pass_target)
		dir = dir.normalized()
		var impulse = dir * pass_power
		if Match.current_match_state != Match.MatchState.IN_GAME:
			Match.current_match_state = Match.MatchState.IN_GAME
			Match.process_match_states()
		#current_player_state = PlayerState.GO_TO_POSITION
		#Match.match_state_changed.emit()
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("pass")
		#await get_tree().create_timer(0.1).timeout
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		#print("Destino de pase: ", receiver.global_position)
		#print("Pasador: ", self.name)
		#print("Receptor: ", receiver.name)
		#print("-------")
		var distance = global_position.distance_to(pass_target)
		ball.set_ball_height(distance, pass_power)
		await get_tree().create_timer(0.3).timeout
		set_collision_mask_value(2, true)
		$DefenseZone.set_collision_mask_value(8, true)
		await get_tree().create_timer(0.7).timeout
		can_move = true
	
	
func pass_ball(receiver : Area2D):
	can_move = false
	look_at(receiver.global_position)
	pass_target = receiver.global_position
	#pass_target = Vector2(-250, receiver.global_position.y) # Prueba de lateral propio
	receiver.current_player_state = PlayerState.RECEIVER
	receiver.behavior_tree()
	#if Match.current_game_mode == Match.GameMode.PLAYER_VS_CPU:
		#if Match.player_controlled == self:
			#Match.player_controlled.user_controlled_player = false
			#Match.player_controlled = null
	
	if ball.player_with_ball == self:
		ball.player_with_ball = null
		set_collision_mask_value(2, false)
		$DefenseZone.set_collision_mask_value(8, false)
		var dir = ball.global_position.direction_to(pass_target)
		dir = dir.normalized()
		var impulse = dir * pass_power
		if Match.current_match_state != Match.MatchState.IN_GAME:
			Match.current_match_state = Match.MatchState.IN_GAME
			Match.process_match_states()
		#current_player_state = PlayerState.GO_TO_POSITION
		#Match.match_state_changed.emit()
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("pass")
		await get_tree().create_timer(0.1).timeout
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		#print("Destino de pase: ", receiver.global_position)
		#print("Pasador: ", self.name)
		#print("Receptor: ", receiver.name)
		#print("-------")
		var distance = global_position.distance_to(pass_target)
		ball.set_ball_height(distance, pass_power)
		await get_tree().create_timer(0.3).timeout 
		set_collision_mask_value(2, true)
		$DefenseZone.set_collision_mask_value(8, true)
		await get_tree().create_timer(0.3).timeout
		current_player_state = PlayerState.GO_TO_POSITION
		can_move = true
		move_animations()
		behavior_tree()
		
		
	
func set_nearest_position(pos) -> Vector2:
	randomize()
	var rand_nearest_x = randi_range(-5, 5)
	var rand_nearest_y = randi_range(-3, 3)
	return Vector2(pos.x + rand_nearest_x, pos.y + rand_nearest_y)
	
	
func gk_saving():
	var rival_gk
	match own_team:
		0:
			rival_gk = Match.gk_1
		_:
			rival_gk = Match.gk_0
	rival_gk.current_player_state = rival_gk.PlayerState.SAVING
	rival_gk.shooter = self
	Match.saver_goalkeeper = rival_gk
	rival_gk.behavior_tree()
	
			

func shot(target_goal):
	if ball.player_with_ball == self:
		can_move = false
		set_collision_mask_value(2, false)
		ball.player_with_ball = null
		#if Match.current_game_mode == Match.GameMode.PLAYER_VS_CPU:
			#if Match.player_controlled == self:
				#Match.player_controlled.user_controlled_player = false
				#Match.player_controlled = null
		var dir = ball.global_position.direction_to(target_goal)
		dir = dir.normalized()
		look_at(target_goal)
		var impulse = dir * (shot_power * 1.2)
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("shot")
		await get_tree().create_timer(0.2).timeout
		ball.apply_central_impulse(impulse)
		Match.audio_shot.play()
		Match.goal_scorer_position = global_position
		gk_saving()
		impact_x_gk_calculate(impulse)
		#var distance = global_position.distance_to(target_goal)
		#ball.set_ball_height(distance, shot_power) por ahora desactivado
		await get_tree().create_timer(0.3).timeout
		set_collision_mask_value(2, true)
		await get_tree().create_timer(0.7).timeout
		if Match.current_match_state != Match.MatchState.STOP_GAME:
			current_player_state = PlayerState.GO_TO_POSITION
		can_move = true
		move_animations()
		behavior_tree()

func shot_user_controlled(dir):
	if ball.player_with_ball == self:
		ball.set_collision_layer_value(2, false)
		can_move = false
		set_collision_mask_value(2, false)
		ball.player_with_ball = null
		#if Match.current_game_mode == Match.GameMode.PLAYER_VS_CPU:
			#if Match.player_controlled == self:
				#Match.player_controlled.user_controlled_player = false
				#Match.player_controlled = null
		#var dir = ball.global_position.direction_to(target_goal)
		#dir = dir.normalized()
		#look_at(target_goal)
		var impulse = dir * shot_power
		ball.linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.play("shot")
		await get_tree().create_timer(0.1).timeout
		Match.audio_shot.play()
		ball.apply_central_impulse(impulse)
		Match.goal_scorer_position = global_position
		gk_saving()
		impact_x_gk_calculate(impulse)
		#var distance = global_position.distance_to(target_goal)
		ball.get_node("AnimatedSprite2D").play("shot_free")
		Match.shadow_ball.play("shot_free")
		Match.shadow_ball.get_node("AnimShadow").play("shot_free")
		#ball.set_ball_height(distance, shot_power) por ahora desactivado
		ball.set_collision_layer_value(2, true)
		await get_tree().create_timer(0.3).timeout
		set_collision_mask_value(2, true)
		await get_tree().create_timer(0.7).timeout
		behavior_tree()
		#current_player_state = PlayerState.GO_TO_POSITION
		can_move = true


func impact_x_gk_calculate(dir_ball):
	var rival_gk
	match own_team:
		0:
			rival_gk = Match.gk_1
		_:
			rival_gk = Match.gk_0
	
	var x0 = ball.global_position.x # posición x de la pelota
	var y0 = ball.global_position.y  # posición y de la pelota
	var Vx = dir_ball.x # dirección x de la pelota
	var Vy = dir_ball.y # dirección y de la pelota
	var y_gk = rival_gk.global_position.y # posición y del arquero
	#var impact_x = (x0 + Vx) * ((y0 - y_gk) / Vy)
	
	var t = (y_gk - y0) / Vy
	var impact_x = x0 + Vx * t
	
	var impact = Vector2(impact_x, y_gk)
	rival_gk.shooter = self
	Match.impact_x.global_position = impact
	Match.saver_goalkeeper.impact_point = impact
	if impact_x > -30 and impact_x < 30: 
		Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_IMPACT_POINT
		Match.saver_goalkeeper.behavior_tree()
	else:
		Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_POSITION
		Match.saver_goalkeeper.behavior_tree()
	


func choice_target_shot(goal):
	randomize()
	var rand_target = randi_range(1, 2) # VOLVER A 3
	if rand_target == 1:
		return goal.get_node("TargetShot/TargetShot1").global_position
	elif rand_target == 2:
		return goal.get_node("TargetShot/TargetShot2").global_position
	else:
		return goal.global_position

func choice_away_target_shot(goal) -> Vector2:
	var target1 = goal.get_node("TargetShot/TargetShot1").global_position
	var target2 = goal.get_node("TargetShot/TargetShot2").global_position
	var rival_gk
	match own_team:
		0:
			rival_gk = Match.gk_1
		_:
			rival_gk = Match.gk_0
	var distance_Target1 = target1.distance_squared_to(rival_gk.global_position)
	var distance_Target2 = target2.distance_squared_to(rival_gk.global_position)
	
	if distance_Target1 < distance_Target2:
		return target2
	else:
		return target1
	
	
	
func set_set_pieces_receiver() -> Area2D:
	match Match.current_restarting_state:
		Match.RestartingState.KICK_OFF:
			return get_parent().restarter2
		Match.RestartingState.GOAL_KICK_0:
			var receivers = get_parent().field_player_list.duplicate(true)
			receivers.erase(self)
			return receivers.pick_random()
		Match.RestartingState.GOAL_KICK_1:
			var receivers = get_parent().field_player_list.duplicate(true)
			receivers.erase(self)
			return receivers.pick_random()
		Match.RestartingState.CORNER_KICK_L_0:
			return get_parent().corner_receivers.pick_random()
		Match.RestartingState.CORNER_KICK_L_1:
			return get_parent().corner_receivers.pick_random()
		Match.RestartingState.CORNER_KICK_R_0:
			return get_parent().corner_receivers.pick_random()
		Match.RestartingState.CORNER_KICK_R_1:
			return get_parent().corner_receivers.pick_random()
		_:
			return option_pass.pick_random()
	

# Chequamos si el receptor está en zona de disparar de primera
func check_ftf() -> bool:
	var check_l : bool = false
	var check_r : bool = false
	if in_ftfl and get_parent().rival_goal.ftf_l_active:
		check_l = true
	if in_ftfr and get_parent().rival_goal.ftf_r_active:
		check_r = true
	
	if in_ftfc or check_l or check_r:
		return true
	else:
		return false

func _on_match_state_changed():
	behavior_tree()


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if Match.saver_goalkeeper:
			Match.saver_goalkeeper.current_player_state = Match.saver_goalkeeper.PlayerState.GO_TO_POSITION
			Match.saver_goalkeeper.behavior_tree()
		Match.last_player_touch_ball = self
		if own_team == 1:
			#if Match.current_game_mode == Match.GameMode.PLAYER_VS_CPU:
				#if Match.player_controlled:
					#Match.player_controlled.user_controlled_player = false
					#Match.player_controlled = null
			#if Match.current_match_state == Match.MatchState.RESTARTING:
				#Match.current_match_state = Match.MatchState.IN_GAME
				#Match.current_team_posesion = own_team
				#Match.match_state_changed.emit()
			player_ia_body_entered(body)
		else:
			if Match.current_game_mode == Match.GameMode.CPU_VS_CPU:
				#if Match.current_match_state == Match.MatchState.RESTARTING:
					#Match.current_match_state = Match.MatchState.IN_GAME
					#Match.current_team_posesion = own_team
					#Match.match_state_changed.emit()
				player_ia_body_entered(body)
			else:
				if Match.player_controlled:
				#if Match.player_controlled != self:
					if Match.player_controlled.own_team == own_team:					
						Match.player_controlled.user_controlled = false
						Match.player_controlled.current_player_state = PlayerState.GO_TO_POSITION
					else:
						Match.player_controlled.current_player_state = PlayerState.NOT_AVAILABLE
				Match.player_controlled = self
				current_player_state = PlayerState.USER_CONTROLLED
				user_controlled = true
				can_move = true
				move = true
				#if Match.current_match_state == Match.MatchState.RESTARTING:
				Match.current_match_state = Match.MatchState.IN_GAME
				Match.process_match_states()
				Match.current_team_posesion = own_team
				Match.match_state_changed.emit() 
				player_user_body_entered(body)
		
		#Match.last_player_touch_ball = self
		#match Match.current_match_state:
			#Match.MatchState.RESTARTING:
				#body.player_with_ball = self
				#Match.receiver = get_parent().restarter2
				#pass_ball(Match.receiver)
			#Match.MatchState.IN_GAME:
				#if body.player_with_ball == null:
					#body.player_with_ball = self
					#if Match.receiver == self:
						#Match.receiver = null
					#else:
						#if Match.receiver:
							#Match.receiver.current_player_state = PlayerState.GO_TO_POSITION
					#current_player_state = PlayerState.WITH_BALL
					#current_player_with_ball = PlayerWithBall.GO_TO_ATTACK_POSITION
					#behavior_tree()
					#Match.current_team_posesion = own_team
					#Match.match_state_changed.emit()
				#else:
					#if body.player_with_ball.field_player:
						#body.player_with_ball.get_node("TimerDecision").stop()
						#if Match.saver_goalkeeper:
							#Match.saver_goalkeeper.current_player_state = PlayerState.GO_TO_POSITION
							#Match.saver_goalkeeper.behavior_tree()
							#Match.saver_goalkeeper = null
					#if own_team != body.player_with_ball.own_team:
						#body.player_with_ball.current_player_state = PlayerState.NOT_AVAILABLE
						#body.player_with_ball.behavior_tree()
					#else:
						#body.player_with_ball.current_player_state = PlayerState.GO_TO_POSITION
						#body.player_with_ball.behavior_tree()
					#body.player_with_ball = self
					#current_player_state = PlayerState.WITH_BALL
					#current_player_with_ball = PlayerWithBall.GO_TO_ATTACK_POSITION
					#Match.current_team_posesion = own_team
					#Match.match_state_changed.emit()
				
	# ACÁ PROGRAMAR LO QUE PASA CON DISTINTOS RESTARTINGS
func player_ia_body_entered(body):
	Match.last_player_touch_ball = self
	Match.current_team_posesion = own_team
	match Match.current_match_state:
		Match.MatchState.RESTARTING:
			body.player_with_ball = self
			Match.receiver = set_set_pieces_receiver()
			pass_ball(Match.receiver)
			Match.current_match_state = Match.MatchState.IN_GAME
			#Probar qué pasa, por qué a veces el rival no saca
			#for player in get_tree().get_nodes_in_group("player"):
				#player.get_node("DefenseZone").set_collision_mask_value(8, true)
			Match.process_match_states()
			Match.match_state_changed.emit()
		Match.MatchState.IN_GAME:
			if body.player_with_ball == null:
				body.player_with_ball = self
				if Match.receiver == self:
					Match.receiver = null
				else:
					if Match.receiver:
						Match.receiver.current_player_state = PlayerState.GO_TO_POSITION
				current_player_state = PlayerState.WITH_BALL
				current_player_with_ball = PlayerWithBall.GO_TO_ATTACK_POSITION
				behavior_tree()
				Match.current_team_posesion = own_team
				Match.match_state_changed.emit()
			else:
				if body.player_with_ball.field_player:
					body.player_with_ball.get_node("TimerDecision").stop()
					if Match.saver_goalkeeper:
						Match.saver_goalkeeper.current_player_state = PlayerState.GO_TO_POSITION
						Match.saver_goalkeeper.behavior_tree()
						Match.saver_goalkeeper = null
				if own_team != body.player_with_ball.own_team:
					var loose_ball = body.player_with_ball
					loose_ball.current_player_state = PlayerState.NOT_AVAILABLE
					#if user_controlled == true or Match.player_controlled:
						#print("El jugador controlado perdió la pelota")
						#print("Equipo con posesión: ", Match.current_team_posesion)
					loose_ball.behavior_tree()
		
				else:
					body.player_with_ball.current_player_state = PlayerState.GO_TO_POSITION
					body.player_with_ball.behavior_tree()
				body.player_with_ball = self
				current_player_state = PlayerState.WITH_BALL
				current_player_with_ball = PlayerWithBall.GO_TO_ATTACK_POSITION
				Match.current_team_posesion = own_team
				Match.match_state_changed.emit()

func player_user_body_entered(body):
	Match.last_player_touch_ball = self
	match Match.current_match_state:
		Match.MatchState.RESTARTING:
			body.player_with_ball = self
			#Match.receiver = get_parent().restarter2
			#pass_ball(Match.receiver)
			Match.receiver = set_set_pieces_receiver()
			pass_ball(Match.receiver)
			for player in get_tree().get_nodes_in_group("player"):
				player.get_node("DefenseZone").set_collision_mask_value(8, true)
		Match.MatchState.IN_GAME:
			if body.player_with_ball == null:
				body.player_with_ball = self
				Match.current_input_buffer_action = Match.InputBufferActions.NOTHING
				Match.current_input_buffer_direction = Match.InputBufferDirection.FORWARD
				if Match.receiver == self:
					Match.receiver = null
					can_move = true
				else:
					if Match.receiver:
						if Match.receiver == self:
							Match.receiver = null
							current_player_state = PlayerState.USER_CONTROLLED
							can_move = true
						else:
							Match.receiver.current_player_state = PlayerState.GO_TO_POSITION
				#current_player_state = PlayerState.WITH_BALL
				#current_player_with_ball = PlayerWithBall.GO_TO_ATTACK_POSITION
				#behavior_tree()
				Match.current_team_posesion = own_team
				Match.match_state_changed.emit()
			else:
				if body.player_with_ball.field_player:
					body.player_with_ball.get_node("TimerDecision").stop()
					if Match.saver_goalkeeper:
						Match.saver_goalkeeper.current_player_state = PlayerState.GO_TO_POSITION
						Match.saver_goalkeeper.behavior_tree()
						Match.saver_goalkeeper = null
				if own_team != body.player_with_ball.own_team:
					body.player_with_ball.current_player_state = PlayerState.NOT_AVAILABLE
					body.player_with_ball.behavior_tree()
				else:
					body.player_with_ball.current_player_state = PlayerState.GO_TO_POSITION
					body.player_with_ball.behavior_tree()
				body.player_with_ball = self
				#current_player_state = PlayerState.WITH_BALL
				#current_player_with_ball = PlayerWithBall.GO_TO_ATTACK_POSITION
				Match.current_team_posesion = own_team
				Match.match_state_changed.emit()


func _on_timer_decision_timeout() -> void:
	#current_player_with_ball = PlayerWithBall.PASS
	#behavior_tree()
	var long_shot = get_parent().rival_goal.in_long_shot_area
	if long_shot:
		randomize()
		var rand_long_shot = randi_range(1, 2)
		if rand_long_shot > 1:
			current_player_with_ball = PlayerWithBall.PASS
			behavior_tree()
		else:
			current_player_with_ball = PlayerWithBall.SHOT
			behavior_tree()
	else:
		current_player_with_ball = PlayerWithBall.PASS
		behavior_tree()


func _on_defense_zone_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if Match.current_match_state == Match.MatchState.IN_GAME:
			if body.player_with_ball:
				if body.player_with_ball.own_team != own_team:
					#await get_tree().create_timer(0.3).timeout
					current_player_state = PlayerState.GO_TO_BALL_ATTACK
					at_target = false
					move = true
					$DefenseZone/DevSprite.modulate.a = 0.5
			else:
				if current_player_state != PlayerState.RECEIVER:
					#await get_tree().create_timer(0.3).timeout
					if user_controlled == false:
						#ACA ESTÁ EL PROBLEMA
						at_target = false
						move = true
						current_player_state = PlayerState.GO_TO_BALL_ATTACK
						$DefenseZone/DevSprite.modulate.a = 0.5
		
				
		


func _on_defense_zone_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		if Match.current_match_state == Match.MatchState.IN_GAME:
			if body.player_with_ball:
				if body.player_with_ball.own_team != own_team:
					if user_controlled == false:
						current_player_state = PlayerState.GO_TO_POSITION
						$DefenseZone/DevSprite.modulate.a = 0.0
						behavior_tree()
				#elif sweeper:
					#current_player_state = PlayerState.GO_TO_POSITION
					#behavior_tree()
			else:
				if current_player_state != PlayerState.RECEIVER:
					if user_controlled == false:
						current_player_state = PlayerState.GO_TO_POSITION
						$DefenseZone/DevSprite.modulate.a = 0.0
						behavior_tree()
				#elif sweeper:
					#current_player_state = PlayerState.GO_TO_POSITION
					#behavior_tree()

func _on_goal_scored(goal):
	if goal.rival_team == own_team:
		current_player_state = PlayerState.GO_TO_CELEBRATION
		behavior_tree()
	
func _on_shot_button_pressed():
	if ball.player_with_ball == self:
		if direction.length() > 0.01:
			shot_user_controlled(direction)
			#shot(choice_target_shot(get_parent().rival_goal))
		else:
			var angle = rotation
			var direction2 = Vector2.RIGHT.rotated(angle)
			shot_user_controlled(direction2)
	else:
		#print("Cambiar de jugador")
		user_controlled = false
		Match.player_controlled	= get_player_controlled()
		#if Match.player_controlled:
		Match.player_controlled.current_player_state = PlayerState.USER_CONTROLLED
		Match.player_controlled.user_controlled = true
		#else:
			#print("ningún jugador controlado")
		#print("Ahora el jugador controlado es: ", Match.player_controlled.name)
		
		current_player_state = PlayerState.GO_TO_POSITION
		behavior_tree()



func _on_animated_sprite_2d_animation_changed() -> void:
	#if current_player_state == PlayerState.WITH_BALL:
		#if $AnimatedSprite2D.animation == "idle":
			#print("animación cambió")
	#if user_controlled:
		#print("Animación Cambiada: ", $AnimatedSprite2D.animation)
	#if $AnimatedSprite2D.animation == "throw_in":
			#print("animación cambió")
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished():
	#if $AnimatedSprite2D.animation == "throw_in":
			#print("animación terminó")
	pass
	


func _on_input_buffer_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		in_input_buffer_zone = true


func _on_input_buffer_area_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		in_input_buffer_zone = false
