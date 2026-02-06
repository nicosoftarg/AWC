extends RigidBody2D

enum BallHeightMachine {
	GROUND,
	LOW,
	MID,
	HEAD,
	OUT_UP_A,
	OUT_UP_B,
}

enum BallMoveMachine {
	IDLE,
	ROLLING,
}

enum BallArcMachine {
	IDLE,
	ASCENDING,
	DESCENDING,
}

#var ball_height : Dictionary[int, String] = {  # Listo para borrar
	#0 : "h0",
	#1 : "h1",
	#2 : "h3",
	#4 : "h4"
#}

@export var friction_per_second : float = 0.3
@export var time_state_height_pass : float = 0.1
@export var time_state_height_shoot : float = 0.3
@export var heading_times_height_state_changes : int = 3

var player_with_ball : Area2D
var ball_in_hand : bool = false
var can_scored : bool = true
var current_ball_height_machine : BallHeightMachine = BallHeightMachine.GROUND
var current_ball_move_machine : BallMoveMachine = BallMoveMachine.IDLE
var current_ball_arc_machine : BallArcMachine = BallArcMachine.IDLE
var max_ball_height : BallHeightMachine = BallHeightMachine.OUT_UP_B
var shadow_offset_x : float = 0.0
var max_pass_distance : float
@onready var kick_off_point : Vector2 = Vector2.ZERO
@onready var anim_shadow: AnimationPlayer = $"../ShadowBallNode/ShadowBall/AnimShadow" # OLD
@onready var root = $".."
@onready var ball_anim_spr : AnimatedSprite2D = $BallAnimSpr
@onready var shadow_ball_spr : Sprite2D = $"../ShadowBallNode/ShadowBallSpr"
@onready var goal_kick_arrow: AnimatedSprite2D = $PassArea/goal_kick_arrow



func _ready():
	max_pass_distance = $PassArea/CollisionShape2D.shape.size.x * 1.5

func _physics_process(delta: float) -> void:
	possession_behavior(delta)
	

func possession_behavior(delta):
	if player_with_ball:
		player_possession()
	else:
		free_ball(delta)
		

func player_possession():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0 
	if player_with_ball.field_player:
		field_player_possession()
	else:
		gk_possession()
	

func free_ball(delta):
	$AnimationPlayer.stop()
	if linear_velocity.length() < 0.5:
		current_ball_move_machine = BallMoveMachine.IDLE
	else:
		current_ball_move_machine = BallMoveMachine.ROLLING
	move_machine()
	match root.current_match_state:
		root.MatchState.STOP_GAME:
			dead_bounce(delta)
		root.MatchState.POSITIONING:
			dead_bounce_reboot()
	
		
func field_player_possession():
	ball_in_hand = false
	global_position = player_with_ball.foot.global_position
	rotation = player_with_ball.rotation
	if player_with_ball.move == true and player_with_ball.can_move: 
		$AnimationPlayer.play("at_foot") 
	else:
		$AnimationPlayer.stop() 
	#field_player_state_correction()

	
func gk_possession():
	set_collision_layer_value(2, false)
	match player_with_ball.current_save_side:
		0:
			global_position = player_with_ball.right_hand.global_position
		1:
			global_position = player_with_ball.center_hand.global_position
		_:
			global_position = player_with_ball.left_hand.global_position
	$AnimationPlayer.stop()
	current_ball_move_machine = BallMoveMachine.IDLE
	move_machine()

	
func field_player_state_correction():
	if player_with_ball != $"..".player_controlled:
		if get_parent().current_input_buffer_action == get_parent().InputBufferActions.NOTHING:
			if player_with_ball.current_player_state != player_with_ball.PlayerState.WITH_BALL:
				player_with_ball.current_player_state = player_with_ball.PlayerState.WITH_BALL
				player_with_ball.behavior_tree()
				print("corrección de estado de jugador")

	
func dead_bounce(delta):
	if current_ball_arc_machine != BallArcMachine.IDLE:
		current_ball_arc_machine = BallArcMachine.DESCENDING # ALTURA
		arc_machine()
	linear_velocity *= pow(friction_per_second, delta)
	angular_velocity *= pow(friction_per_second, delta)


func dead_bounce_reboot():
	current_ball_arc_machine = BallArcMachine.IDLE
	current_ball_height_machine = BallHeightMachine.GROUND
	current_ball_move_machine = BallMoveMachine.IDLE
	if get_parent().current_team_posesion == 0:
		look_at($"../Stage/Goal1".global_position)
	else:
		look_at($"../Stage/Goal0".global_position)
	move_machine()
	arc_machine()
	

func move_machine():
	match current_ball_move_machine:
		BallMoveMachine.IDLE:
			ball_anim_spr.speed_scale = 0
		BallMoveMachine.ROLLING:
			ball_anim_spr.speed_scale = 1


func height_machine():
	match current_ball_height_machine:
		BallHeightMachine.GROUND:
			ball_anim_spr.play("0_ground")
			shadow_offset_x = 1.0
			set_collision_layer_value(2, true)
		BallHeightMachine.LOW:
			ball_anim_spr.play("1_low")
			shadow_offset_x = 2.0
			set_collision_layer_value(2, true)
		BallHeightMachine.MID:
			ball_anim_spr.play("2_mid")
			shadow_offset_x = 4.0
			set_collision_layer_value(2, true)
		BallHeightMachine.HEAD:
			ball_anim_spr.play("3_head")
			shadow_offset_x = 6.0
			set_collision_layer_value(2, true)
		BallHeightMachine.OUT_UP_A:
			ball_anim_spr.play("4_out_up_a")
			shadow_offset_x = 8.0
			set_collision_layer_value(2, false)
		BallHeightMachine.OUT_UP_B:
			ball_anim_spr.play("5_out_up_b")
			shadow_offset_x = 16.0
			set_collision_layer_value(2, false)

	shadow_ball_spr.global_position.x =  $"../ShadowBallNode".global_position.x + shadow_offset_x
	shadow_ball_spr.frame = current_ball_height_machine
	

func arc_machine():
	match current_ball_arc_machine:
		BallArcMachine.IDLE:
			$ArcTimer.stop()
		BallArcMachine.ASCENDING:
			if current_ball_height_machine >= max_ball_height:
				current_ball_arc_machine = BallArcMachine.DESCENDING
			else:
				current_ball_height_machine += 1
		BallArcMachine.DESCENDING:
			if current_ball_height_machine == BallHeightMachine.GROUND:
				current_ball_arc_machine = BallArcMachine.IDLE
			else:
				current_ball_height_machine -= 1
	height_machine()


func set_max_ball_height(distance, power, impulse_type):
	current_ball_arc_machine = BallArcMachine.ASCENDING
	if distance < 40:
		max_ball_height = BallHeightMachine.GROUND
	elif distance < 60:
		max_ball_height = BallHeightMachine.LOW
	elif distance < 80:
		max_ball_height = BallHeightMachine.MID
	elif distance < 100:
		max_ball_height = BallHeightMachine.HEAD
	elif distance < 120:
		max_ball_height = BallHeightMachine.OUT_UP_A
	else:
		max_ball_height = BallHeightMachine.OUT_UP_B
	
	match impulse_type:
		0:
			$ArcTimer.wait_time = time_state_height_pass
		1:
			$ArcTimer.wait_time = time_state_height_shoot
			if max_ball_height > 3:
				max_ball_height = 3
		2:
			$ArcTimer.wait_time = set_time_state_height_heading(distance, power)
	$ArcTimer.start()


func set_time_state_height_heading(distance, power) -> float:
	var total_time = distance / power
	return total_time / heading_times_height_state_changes


func reset_ball():
	current_ball_arc_machine = BallArcMachine.IDLE 
	current_ball_height_machine = BallHeightMachine.GROUND
	#height_machine()
	arc_machine()

func _on_arc_timer_timeout():
	arc_machine()
	
