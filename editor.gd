extends Control

@onready var text_display = $Label
@onready var cursor = $Cursor

var text = []
var font_size = 64
var character_size
var window_size
var cursor_position = Vector2i(0, 0)
func _ready():
	var font: FontFile = load("res://RobotoMono.ttf")
	character_size = font.get_string_size("t", 0, -1, font_size)
	window_size = get_viewport().get_visible_rect().size
	cursor.size = Vector2(character_size.x/5, character_size.y)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var pos = Vector2i(event.position/character_size)
			prints(pos)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE:
			text.pop_back()
		elif 65 <= event.keycode and event.keycode <= 90:
			var key = OS.get_keycode_string(event.keycode)
			if not Input.is_key_pressed(KEY_SHIFT):
				text.append(key.to_lower())
			else:
				text.append(key)
		display_text()

func display_text():
	var current_text = ""
	var current_size = 0
	var current_y = 0
	var current_x = 0
	for i in range(len(text)):
		current_size += character_size.x
		current_x += 1
		if current_size > window_size.x:
			current_text += "\n"
			current_size = character_size.x
			current_y += 1
			current_x = 1
		current_text += text[i]
		cursor_position = Vector2i(current_x, current_y)
	text_display.text = current_text
	update_cursor()
func update_cursor():
	cursor.position = Vector2(cursor_position)*character_size
