extends Control

@onready var text_display = $Text
@onready var buffer_display = $BufferText
@onready var cursor = $Cursor

var font_size := 64
var character_size: Vector2
var window_size: Vector2
var gap_buffer: GapBuffer
func _ready():
	var font: FontFile = load("res://RobotoMono.ttf")
	character_size = font.get_string_size("t", 0, -1, font_size)
	window_size = get_viewport().get_visible_rect().size
	cursor.size = Vector2(character_size.x/10, character_size.y)
	gap_buffer = GapBuffer.new()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var pos = Vector2i(event.position/character_size)
			var text = gap_buffer.buffer
			var current_size = 0
			var counter = 0
			var cursor_position = Vector2i(0, 0)
			for i in range(len(text)):
				current_size += character_size.x
				if current_size > window_size.x or text[i] == '\n':
					current_size = character_size.x
					cursor_position.x = 0
					cursor_position.y += 1
					counter += 1
					if cursor_position == pos:
						break
				if text[i] not in [null, '\n']:
					cursor_position.x += 1
					counter += 1
					if cursor_position == pos:
						break
			gap_buffer.set_cursor(counter)
			buffer_display.text = gap_buffer.raw()
			update_cursor(cursor_position)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE:
			gap_buffer.backspace()
		if event.keycode == KEY_DELETE:
			gap_buffer.delete()
		elif event.keycode == KEY_SPACE:
			gap_buffer.insert(" ")
		elif event.keycode == KEY_ENTER:
			gap_buffer.insert('\n')
		elif event.keycode == KEY_LEFT:
			gap_buffer.move_cursor(-1)
		elif event.keycode == KEY_RIGHT:
			gap_buffer.move_cursor(1)
		elif 65 <= event.keycode and event.keycode <= 90:
			var key = OS.get_keycode_string(event.keycode)
			if not Input.is_key_pressed(KEY_SHIFT):
				key = key.to_lower()
			gap_buffer.insert(key)
		display_text()

func display_text():
	var text = gap_buffer.buffer
	var current_text = ""
	var current_size = 0
	var counter = 0
	var cursor_position = Vector2i(0, 0)
	for i in range(len(text)):
		current_size += character_size.x
		if current_size > window_size.x or text[i] == '\n':
			current_text += "\n"
			current_size = character_size.x
			if text[i] == '\n' and counter != gap_buffer.cursor_position:
				cursor_position.x = 0
				cursor_position.y += 1
				counter += 1
		if text[i] not in [null, '\n']:
			current_text += text[i]
			if counter != gap_buffer.cursor_position:
				cursor_position.x += 1
				counter += 1
	text_display.text = current_text
	buffer_display.text = gap_buffer.raw()
	await get_tree().process_frame
	buffer_display.position = text_display.position + Vector2(0, text_display.size.y)
	update_cursor(cursor_position)
func update_cursor(cursor_position):
	cursor.position = text_display.position + Vector2(cursor_position)*character_size

