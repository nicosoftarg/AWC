extends Area2D

enum PlayerState {
	GO_TO_GK_POSITION,
	GO_TO_IMPACT_POINT,
	GO_TO_BALL,
	WITH_BALL,
	PASSING,
	SAVING,
	BOUNCING,
}

enum SaveSide {
	RIGHT,
	CENTER,
	LEFT,
}


enum Action {
	IDLE,
	SAVE,
	WAKE_UP,
	UP_KICK,
}
# Variables Externas
@export var user_player_speed : float = 35.0
@export var cpu_player_speed : float = 30.0
@export var own_team : int = 0
@export var pass_power : float
@export var own_tactic_zone : int 
var bounces_dict : Dictionary[String, int]
var bounces_steps : Array[int]
var bounce_target : Vector2
var field_player : bool = false
var option_pass : Array[Area2D]
var move : bool = false
var direction : Vector2
var shooter : Area2D
var impact_point : Vector2
var current_save_side : SaveSide = SaveSide.CENTER
var current_player_state : PlayerState = PlayerState.GO_TO_GK_POSITION
var target : Vector2
var pass_target : Vector2
var can_move : bool = true
@onready var ball = get_tree().get_first_node_in_group("ball")
@onready var Match = get_tree().get_first_node_in_group("match")
@onready var center_hand: Marker2D = $Hand
@onready var right_hand: Marker2D = $RightHand
@onready var left_hand: Marker2D = $LeftHand
@onready var own_goal : Node2D = get_parent().own_goal
@onready var hand : Marker2D = center_hand
@onready var support_scripts = $SecondaryScripts/SupportScripts
@onready var event_behavior_tree = $SecondaryScripts/EventBehaviorTree
@onready var update_behavior_tree_script = $SecondaryScripts/UpdateBehaviorTree

# dEBUG
var last_state : PlayerState


func _ready() -> void:
	own_team = get_parent().team
	Match.match_state_changed.connect(_on_match_state_changed)
	await get_tree().create_timer(0.1).timeout
	call_deferred("deferred_functions")


func deferred_functions():
	support_scripts.set_player_level(self)
	support_scripts.set_bounces_steps(bounces_steps, bounces_dict)


func _physics_process(delta):
	update_behavior_tree(delta)


func _on_match_state_changed():
	behavior_tree()
	
	
func behavior_tree():
	event_behavior_tree.event_behavior_tree(Match, self, ball)

		
func search_nearest_position() -> Vector2:
	var min_distance : float = get_parent().own_goal.positions_gk[0].global_position.distance_squared_to(ball.global_position)
	var min_point : Vector2 = get_parent().own_goal.positions_gk[0].global_position
	for point in get_parent().own_goal.positions_gk:
		var distance = point.global_position.distance_squared_to(ball.global_position)
		if distance < min_distance:
			min_distance = distance
			min_point = point.global_position
	return Vector2(min_point.x, own_goal.positions_gk[0].global_position.y)
			

func update_behavior_tree(delta):
	update_behavior_tree_script.animations_state_machine(Match, self, ball)
	if move and can_move:
		movement(delta)
	
	
					

func movement(delta):
	direction = global_position.direction_to(target)
	direction = direction.normalized()
	var speed : float
	if own_team == 0:
		speed = user_player_speed
	else:
		speed= cpu_player_speed
	var velocity = direction * speed * delta
	global_position += velocity


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		Match.logical_methods.clear_input_buffer(Match)
		#Match.current_input_buffer_action = Match.InputBufferActions.NOTHING
		#Match.current_input_buffer_direction = Match.InputBufferDirection.FORWARD
		if is_bounced():
			bounce()
			#var dir = ball.global_position.direction_to(bounce_target)
			#dir = dir.normalized()
			#var impulse : Vector2 =  dir * (ball.linear_velocity.length() / 2.5)
			#ball.linear_velocity = Vector2.ZERO
			#Match.last_player_touch_ball = self
			#Match.saver_goalkeeper = null
			#ball.apply_central_impulse(impulse)
			#current_player_state = PlayerState.BOUNCING
			#behavior_tree()
		else:
			no_bounce(body)
			#ball.current_ball_arc_machine = ball.BallArcMachine.IDLE # ALTURA
			#ball.current_ball_height_machine = ball.BallHeightMachine.GROUND # ALTURA
			#ball.height_machine()
			#ball.arc_machine()
			#Match.last_player_touch_ball = self
			#Match.saver_goalkeeper = null
			#set_collision_mask_value(2, false)
			#set_collision_mask_value(8, false)
			#match Match.current_match_state:
				#Match.MatchState.IN_GAME:
					#if body.player_with_ball == null:
						#body.ball_in_hand = true
						#body.player_with_ball = self
						#if Match.receiver:
							#Match.receiver.current_player_state = Match.receiver.PlayerState.GO_TO_POSITION
							#Match.receiver = null
						#current_player_state = PlayerState.WITH_BALL
						#Match.current_team_posesion = own_team
						#Match.match_state_changed.emit()
					#else:
						#if body.player_with_ball.field_player:
							#body.player_with_ball.get_node("TimerDecision").stop()
						#if own_team != body.player_with_ball.own_team:
							#body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.NOT_AVAILABLE
							#body.player_with_ball.behavior_tree()
						#else:
							#if body.player_with_ball.field_player:
								#body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.GO_TO_POSITION
								#body.player_with_ball.behavior_tree()
						#body.player_with_ball = self
						#current_player_state = PlayerState.WITH_BALL
						#Match.current_team_posesion = own_team
						#Match.match_state_changed.emit()

func bounce():
	var dir = ball.global_position.direction_to(bounce_target)
	dir = dir.normalized()
	var impulse : Vector2 =  dir * (ball.linear_velocity.length() / 2.5)
	ball.linear_velocity = Vector2.ZERO
	Match.last_player_touch_ball = self
	Match.saver_goalkeeper = null
	ball.apply_central_impulse(impulse)
	current_player_state = PlayerState.BOUNCING
	behavior_tree()	


func no_bounce(body):
	ball.reset_ball()
	#ball.current_ball_arc_machine = ball.BallArcMachine.IDLE # ALTURA
	#ball.current_ball_height_machine = ball.BallHeightMachine.GROUND # ALTURA
	#ball.height_machine()
	#ball.arc_machine()
	Match.last_player_touch_ball = self
	Match.saver_goalkeeper = null
	set_collision_mask_value(2, false)
	set_collision_mask_value(8, false)
	if Match.current_match_state == Match.MatchState.IN_GAME:
		if body.player_with_ball == null:
			if_free_ball(body)
			#body.ball_in_hand = true
			#body.player_with_ball = self
			#if Match.receiver:
				#Match.receiver.current_player_state = Match.receiver.PlayerState.GO_TO_POSITION
				#Match.receiver = null
			#current_player_state = PlayerState.WITH_BALL
			#Match.current_team_posesion = own_team
			#Match.match_state_changed.emit()
		else:
			if_not_free_ball(body)
			#if body.player_with_ball.field_player:
				#body.player_with_ball.get_node("TimerDecision").stop()
			#if own_team != body.player_with_ball.own_team:
				#body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.NOT_AVAILABLE
				#body.player_with_ball.behavior_tree()
			#else:
				#if body.player_with_ball.field_player:
					#body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.GO_TO_POSITION
					#body.player_with_ball.behavior_tree()
			#body.player_with_ball = self
			#current_player_state = PlayerState.WITH_BALL
			#Match.current_team_posesion = own_team
			#Match.match_state_changed.emit()


func if_free_ball(body):
	body.ball_in_hand = true
	body.player_with_ball = self
	if Match.receiver:
		Match.receiver.current_player_state = Match.receiver.PlayerState.GO_TO_POSITION
		Match.receiver = null
	current_player_state = PlayerState.WITH_BALL
	Match.current_team_posesion = own_team
	Match.match_state_changed.emit()


func if_not_free_ball(body):
	if body.player_with_ball.field_player:
		body.player_with_ball.get_node("TimerDecision").stop()
	if own_team != body.player_with_ball.own_team:
		body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.NOT_AVAILABLE
		body.player_with_ball.behavior_tree()
	else:
		if body.player_with_ball.field_player:
			body.player_with_ball.current_player_state = body.player_with_ball.PlayerState.GO_TO_POSITION
			body.player_with_ball.behavior_tree()
	body.player_with_ball = self
	current_player_state = PlayerState.WITH_BALL
	Match.current_team_posesion = own_team
	Match.match_state_changed.emit()

func is_bounced() -> bool:
	var temp_bounce = own_goal.get_gk_bounces_position(self, current_save_side)
	if temp_bounce == Vector2.ZERO:
		return false
	else:
		bounce_target = temp_bounce
		return true

func shoot_monitor():
	if ball.player_with_ball == null:
		if Match.current_tactic_zone == own_tactic_zone:
			if own_team == 0:
				if ball.linear_velocity.y > 0:
					shoot_monitor_calculate()
			else:
				if ball.linear_velocity.y < 0:
					shoot_monitor_calculate()	
					
func shoot_monitor_calculate():
	var time = (global_position.y - ball.global_position.y) / ball.linear_velocity.y
	if time > 0 and time < 1.5:
		var impact_x = ball.global_position.x + ball.linear_velocity.x * time
		if impact_x > (own_goal.global_position.x -25) and impact_x < (own_goal.global_position.x + 25):
			impact_point = Vector2(impact_x, global_position.y)
			save_free_ball()
			

func save_free_ball():
	if current_player_state != PlayerState.BOUNCING or current_player_state != PlayerState.SAVING:
		current_player_state = PlayerState.GO_TO_IMPACT_POINT
		if own_team == 0:
			if Match.get_node("Players/Team1/Gk").current_player_state != PlayerState.BOUNCING:
				Match.get_node("Players/Team1/Gk").current_player_state = PlayerState.GO_TO_GK_POSITION
		else:
			if Match.get_node("Players/Team0/Gk").current_player_state != PlayerState.BOUNCING:
				Match.get_node("Players/Team0/Gk").current_player_state = PlayerState.GO_TO_GK_POSITION
		behavior_tree()


func saving(save_side):
	current_player_state = PlayerState.SAVING
	$RightSide.set_collision_mask_value(8, false)
	$CenterSide.set_collision_mask_value(8, false)
	$LeftSide.set_collision_mask_value(8, false)
	save_side_machine(save_side)
	
			
func save_side_machine(save_side):
	match save_side:
		SaveSide.RIGHT:
			$AnimatedSprite2D.flip_v = false
			hand = right_hand
		SaveSide.LEFT:
			$AnimatedSprite2D.flip_v = true
			hand = left_hand
		SaveSide.CENTER:
			if own_team == 0:
				if target.x >= global_position.x:
					save_side_machine(SaveSide.RIGHT)
				else:
					save_side_machine(SaveSide.LEFT)
			else:
				if target.x <= global_position.x:
					save_side_machine(SaveSide.RIGHT)
				else:
					save_side_machine(SaveSide.LEFT)


			

func _on_right_side_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		saving(SaveSide.RIGHT)


func _on_left_side_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		saving(SaveSide.LEFT)


func _on_center_side_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		saving(SaveSide.CENTER)


func _on_shot_monitor_timer_timeout() -> void:
	shoot_monitor()
