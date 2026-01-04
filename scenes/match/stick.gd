extends Area2D

@onready var sprite_base_stick = $SpriteBaseStick
@onready var sprite_stick = $SpriteStick
@onready var radio = $CollisionShape2D.shape.radius
var direction : Vector2


func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if global_position.distance_to(event.position) <= radio:
				sprite_stick.global_position = event.position
				direction = global_position.direction_to(sprite_stick.global_position)
			else:
				direction = global_position.direction_to(sprite_stick.global_position)
				sprite_stick.position = direction * radio
				
		else:
			sprite_stick.position = Vector2.ZERO
			direction = Vector2.ZERO
	
	if event is InputEventScreenDrag:
		if global_position.distance_to(event.position) <= radio:
			sprite_stick.global_position = event.position
			direction = global_position.direction_to(sprite_stick.global_position)

		else:
			#direction = global_position.direction_to(sprite_stick.global_position)
			#sprite_stick.position = direction * radio
			sprite_stick.position = Vector2.ZERO
			direction = Vector2.ZERO
		
		
