extends Node


func clear_input_buffer(Match):
	Match.current_input_buffer_action = Match.InputBufferActions.NOTHING
	Match.current_input_buffer_direction = Match.InputBufferDirection.FORWARD
	
