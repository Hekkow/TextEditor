extends ColorRect

var dragging = false
signal drag_horizontal(x: float)
signal drag_vertical(y: float)
var clicked_position

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				clicked_position = event.position
				dragging = true
			else:
				dragging = false
	if dragging:
		drag_horizontal.emit(event.global_position.x - clicked_position.x)
		drag_vertical.emit(event.global_position.y - clicked_position.y)
