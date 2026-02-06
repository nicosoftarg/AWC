extends Node

@onready var root = $"../.."


func search_nearest_defense_point() -> Vector2:
	var min_distance : float = root.global_position.distance_squared_to(root.ball.global_position)
	var min_point : Vector2 = root.ball.global_position
	for point in root.defense_points:
		var distance = root.global_position.distance_squared_to(point.global_position)
		if distance < min_distance:
			min_distance = distance
			min_point = point.global_position
	return min_point


func choice_away_target_shot(goal) -> Vector2:
	var target1 = goal.get_node("TargetShot/TargetShot1").global_position
	var target2 = goal.get_node("TargetShot/TargetShot2").global_position
	var rival_gk : Area2D
	match root.own_team:
		0:
			rival_gk = root.Match.gk_1
		_:
			rival_gk = root.Match.gk_0
	var distance_Target1 = target1.distance_squared_to(rival_gk.global_position)
	var distance_Target2 = target2.distance_squared_to(rival_gk.global_position)
	
	if distance_Target1 < distance_Target2:
		return target2
	else:
		return target1



	
