extends Node2D

signal Goal(goal)

enum BounceTypes {
	NO_BOUNCE,
	GOOD_BOUNCE,
	CORNER_BOUNCE,
	BAD_BOUNCE,
	GOAL_BOUNCE,
}

enum BounceSides {
	LEFT,
	RIGHT,
	CENTER,
}

var current_bounce_type : BounceTypes = BounceTypes.NO_BOUNCE
var current_bounce_side : BounceSides = BounceSides.LEFT
var current_bounce : Marker2D

var positions_gk : Array[Marker2D]
#var gk_bounces : Array[Marker2D]
var in_long_shot_area : bool = false
var in_aerial_pass_zone : bool = false
var ftf_l_active : bool = false
var ftf_r_active : bool = false
@export var rival_team : int
@onready var ball = get_tree().get_first_node_in_group("ball")
@onready var gk_position: Marker2D = $PivotGK/GkPosition
@onready var sweeper_position: Marker2D = $PivotSweeper/SweeperPosition
@onready var Match = get_tree().get_first_node_in_group("match")

func _ready() -> void:
	positions_gk_append()
	#gk_bounces_append()
	


func _physics_process(_delta: float) -> void:
	$PivotGK.look_at(ball.global_position)
	$PivotSweeper.look_at(ball.global_position)


func positions_gk_append():
	positions_gk.append($"PositionsGK/1")
	positions_gk.append($"PositionsGK/2")
	positions_gk.append($"PositionsGK/3")
	positions_gk.append($"PositionsGK/4")
	positions_gk.append($"PositionsGK/5")
	positions_gk.append($"PositionsGK/6")
	positions_gk.append($"PositionsGK/7")
	

#func gk_bounces_append():
	#gk_bounces.append($GkBounces/Corner1)
	#gk_bounces.append($GkBounces/Corner2)
	#gk_bounces.append($GkBounces/Side1)
	#gk_bounces.append($GkBounces/Side2)
	#gk_bounces.append($GkBounces/Goal1)
	#gk_bounces.append($GkBounces/Goal2)


func get_gk_bounces_position(gk, side_save) -> Vector2:
	current_bounce_type = get_bounce_type(gk)
	match current_bounce_type:
		BounceTypes.NO_BOUNCE:
			print("Atajó el arquero sin dar rebote")
			return Vector2.ZERO
		BounceTypes.GOOD_BOUNCE:
			match side_save:
				gk.SaveSide.RIGHT:
					return $GkBounces/GooDR.global_position
				_:
					return $GkBounces/GooDL.global_position
		BounceTypes.CORNER_BOUNCE:
			match side_save:
				gk.SaveSide.RIGHT:
					return $GkBounces/CornerR.global_position
				_:
					return $GkBounces/CornerL.global_position
		BounceTypes.BAD_BOUNCE:
			match side_save:
				gk.SaveSide.RIGHT:
					return $GkBounces/BadR.global_position
				_:
					return $GkBounces/BadL.global_position
		_:
		#BounceTypes.GOAL_BOUNCE:
			match side_save:
				gk.SaveSide.RIGHT:
					return $GkBounces/GoalR.global_position
				_:
					return $GkBounces/GoalL.global_position


func get_bounce_type(gk) -> BounceTypes:
	randomize()
	# acá se podría leer la cantidad de datos en el array y lo que suman todos
	# en base a eso habría que construir los bloques de código, que serían iguales a la cantidad de datos del array
	var rand_bounce : int = randi_range(0 , 99)
	print("El rand del rebote es: ", rand_bounce)
	print(gk.bounces_steps)
	if rand_bounce < gk.bounces_steps[0]:
		print(str(rand_bounce) + " es menor que " + str(gk.bounces_steps[0]))
		print("No hay rebote")
		return BounceTypes.NO_BOUNCE
	elif rand_bounce >= gk.bounces_steps[0] and rand_bounce < gk.bounces_steps[1]:
		print(str(rand_bounce) + " es mayor que " + str(gk.bounces_steps[0]) + " y menor que " + str(gk.bounces_steps[1]))
		print("Rebote Bueno")
		return BounceTypes.GOOD_BOUNCE
	elif rand_bounce >= gk.bounces_steps[1] and rand_bounce < gk.bounces_steps[2]:
		print(str(rand_bounce) + " es mayor que " + str(gk.bounces_steps[1]) + " y menor que " + str(gk.bounces_steps[2]))
		print("Rebote Corner")
		return BounceTypes.CORNER_BOUNCE
	elif rand_bounce >= gk.bounces_steps[2] and rand_bounce < gk.bounces_steps[3]:
		print(str(rand_bounce) + " es mayor que " + str(gk.bounces_steps[2]) + " y menor que " + str(gk.bounces_steps[3]))
		print("Mal Rebote")
		return BounceTypes.BAD_BOUNCE
	else:
		print(str(rand_bounce) + " es mayor que " + str(gk.bounces_steps[3]) + " y menor que " + str(gk.bounces_steps[4]))
		print("Rebote Gol")
		return BounceTypes.GOAL_BOUNCE
		

func _on_shot_area_area_entered(area: Area2D) -> void:
	if area.own_team == rival_team:
		area.in_shot_area = true
		if area == ball.player_with_ball:
			area.get_node("TimerDecision").stop()
			area.current_player_with_ball = area.PlayerWithBall.SHOT
			area.behavior_tree()


func _on_shot_area_area_exited(area: Area2D) -> void:
	if area.own_team == rival_team:
		area.in_shot_area = false


func _on_goal_line_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.can_scored:
			body.can_scored = false
			Goal.emit(self)


func _on_gk_for_ball_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if ball.player_with_ball:
			if ball.player_with_ball.own_team == rival_team:
				if rival_team == 0:
					Match.gk_1.current_player_state = Match.gk_1.PlayerState.GO_TO_BALL
				else:
					Match.gk_0.current_player_state = Match.gk_0.PlayerState.GO_TO_BALL
	


func _on_gk_for_ball_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		if rival_team == 0:
				if Match.gk_1.can_move:
					Match.gk_1.current_player_state = Match.gk_1.PlayerState.GO_TO_GK_POSITION
					Match.gk_1.behavior_tree()
		else:
			if Match.gk_0.can_move:
				Match.gk_0.current_player_state = Match.gk_0.PlayerState.GO_TO_GK_POSITION
				Match.gk_0.behavior_tree()



func _on_long_shot_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		in_long_shot_area = true
		


func _on_long_shot_area_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		in_long_shot_area = false


func _on_areal_pass_l_body_entered(body):
	if body is RigidBody2D:
		in_aerial_pass_zone = true
		ftf_r_active = true


func _on_areal_pass_l_body_exited(body):
	if body is RigidBody2D:
		in_aerial_pass_zone = false
		ftf_r_active = false


func _on_areal_pass_r_body_entered(body):
	if body is RigidBody2D:
		in_aerial_pass_zone = true
		ftf_l_active = true


func _on_areal_pass_r_body_exited(body):
	if body is RigidBody2D:
		in_aerial_pass_zone = false
		ftf_l_active = false


func _on_ftfc_area_entered(area):
	if area.own_team == rival_team:
		area.in_ftfc = true



func _on_ftfc_area_exited(area):
	if area.own_team == rival_team:
		area.in_ftfc = false


func _on_ftfl_area_entered(area):
	if area.own_team == rival_team:
		area.in_ftfl = true



func _on_ftfl_area_exited(area):
	if area.own_team == rival_team:
		area.in_ftfl = false


func _on_ftflr_area_entered(area):
	if area.own_team == rival_team:
		area.in_ftfr = true



func _on_ftflr_area_exited(area):
	if area.own_team == rival_team:
		area.in_ftfr = false
