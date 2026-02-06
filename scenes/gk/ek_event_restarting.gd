extends Node

func restarting(self_gk):
	self_gk.current_save_side = self_gk.SaveSide.CENTER
	self_gk.hand = self_gk.center_hand
	self_gk.get_node("RightSide").set_collision_mask_value(8, true)
	self_gk.get_node("LeftSide").set_collision_mask_value(8, true)
