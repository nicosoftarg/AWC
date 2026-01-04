extends Panel

var is_touching : bool = false
var touch_start := Vector2.ZERO
var direction := Vector2.ZERO

@onready var stick_visual: TextureRect = $StickVisual
@onready var touch_zone: Control = $TouchZone

#func _ready() -> void:
	#touch_zone.gui_input.connect(_on_touch_zone_input)
	
	
func _on_touch_zone_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_touching = true
				direction = Vector2.ZERO
				touch_start = event.position
				stick_visual.visible = true
				stick_visual.position = touch_start - stick_visual.size / 2
		else:
			is_touching = false
			direction = Vector2.ZERO
			stick_visual.visible = false
	elif event is InputEventMouseMotion and is_touching:
		var delta = event.position - touch_start
		direction = delta.normalized()
		#acá se podría normalizar la dirección
		stick_visual.position = event.position - stick_visual.size / 2
