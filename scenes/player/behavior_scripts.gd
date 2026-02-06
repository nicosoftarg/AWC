extends Node

@onready var update_behavior_scripts = $UpdateBehaviorScripts
@onready var event_behavior_scripts = $EventBehaviorScripts


func update_behavior_tree(self_player, match_root, ball):
	update_behavior_scripts.update_behavior_tree(self_player, match_root, ball)
	

func event_behavior_tree(self_player, Match, ball):
	event_behavior_scripts.event_behavior_tree(self_player, Match, ball)
	
