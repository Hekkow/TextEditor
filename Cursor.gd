extends ColorRect

var timer: Timer
func _ready():
	timer = Timer.new()
	timer.timeout.connect(toggle_visibility)
	timer.wait_time = 1
	timer.autostart = true
	add_child(timer)
func toggle_visibility():
	if visible:
		visible = false
	else:
		visible = true
	timer.start()
