extends Sprite2D

var initial_x



func _ready():
	scale = Vector2(0.25, 0.25)
	change_color_and_x()

func _physics_process(delta):
	if global_position.y > 140:
		randomize()
		change_color_and_x()
		var randy = randi_range(-10, -30)
		global_position.y = randy
	else:
		global_position.y += 20 * delta
		if global_position.x < (initial_x + 5):
			global_position.x += 1 * delta
		else:
			if global_position.x > (initial_x - 5):
				global_position.x -= 1 * delta
			
		
func change_color_and_x():
	randomize()
	var rand_color = randi_range(1, 7)
	modulate = change_color(rand_color)
	initial_x = randi_range(0, 240)
	global_position.x = initial_x
	
	
	
func change_color(rand_color) -> Color:
	match rand_color:
		1:
			return Color.RED
		2:
			return Color.SKY_BLUE
		3:
			return Color.GREEN
		4:
			return Color.YELLOW
		5:
			return Color.ORANGE_RED
		6:
			return Color.WHITE_SMOKE
		_:
			return Color.HOT_PINK
