extends Control

@onready var text_display = $Text
@onready var buffer_display = $BufferText
@onready var cursor = $Cursor
@onready var horizontal_scrollbar = $HorizontalScrollbar
@onready var vertical_scrollbar = $VerticalScrollbar
@onready var row_column_display = $RowColumn

var font_size := 128
var character_size: Vector2
var window_size: Vector2
var gap_buffer: GapBuffer
var max_width = 1 # cant be 0 because of division by 0
var max_height = 1
var cursor_position: Vector2i
func _ready():
	var font: FontFile = load("res://RobotoMono.ttf")
	character_size = font.get_string_size("t", 0, -1, font_size)
	window_size = get_viewport().get_visible_rect().size
	cursor.size = Vector2(character_size.x/10, character_size.y)
	gap_buffer = GapBuffer.new()
	horizontal_scrollbar.drag_horizontal.connect(scroll_horizontal)
	horizontal_scrollbar.position = Vector2(0, window_size.y - horizontal_scrollbar.size.y)
	vertical_scrollbar.drag_vertical.connect(scroll_vertical)
	vertical_scrollbar.position = Vector2(window_size.x - vertical_scrollbar.size.x, 0)
	update_scrollbar()
func scroll_horizontal(x: float):
	if x < 0:
		x = 0
	elif x+horizontal_scrollbar.size.x > window_size.x:
		x = window_size.x - horizontal_scrollbar.size.x
	var scroll_percent = x / (window_size.x - horizontal_scrollbar.size.x)
	horizontal_scrollbar.position = Vector2(x, horizontal_scrollbar.position.y)
	text_display.position = Vector2((-max_width+window_size.x-cursor.size.x)*scroll_percent, text_display.position.y)
	update_cursor(cursor_position)
func scroll_vertical(y: float):
	if y < 0:
		y = 0
	elif y+vertical_scrollbar.size.y > window_size.y:
		y = window_size.y - vertical_scrollbar.size.y
	var scroll_percent = y / (window_size.y - vertical_scrollbar.size.y)
	vertical_scrollbar.position = Vector2(vertical_scrollbar.position.x, y)
	text_display.position = Vector2(text_display.position.x, (-max_height+window_size.y)*scroll_percent)
func update_scrollbar():
	if window_size.x > max_width:
		horizontal_scrollbar.hide()
	else:
		horizontal_scrollbar.show()
		var percent = window_size.x/max_width
		horizontal_scrollbar.size = Vector2(window_size.x*percent, horizontal_scrollbar.size.y)
	if window_size.y > max_height:
		vertical_scrollbar.hide()
	else:
		vertical_scrollbar.show()
		var percent = window_size.y/max_height
		vertical_scrollbar.size = Vector2(vertical_scrollbar.size.x, window_size.y*percent)
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
	var text = gap_buffer.pretty()
	var current_text = ""
	var current_size = 0
	max_width = 1
	max_height = character_size.y
	var counter = 0 # stops incrementing when counter reaches cursor position
	cursor_position = Vector2i(0, 0)
	
	for i in range(len(text)):
		if text[i] != '\n':
			current_size += character_size.x
			if current_size > max_width:
				max_width = current_size
		if text[i] == '\n':
			current_text += "\n"
			max_height += character_size.y
			current_size = 0
			if counter != gap_buffer.cursor_position:
				cursor_position.x = 0
				cursor_position.y += 1
				counter += 1
		elif text[i] not in [null, '\n']:
			current_text += text[i]
			if counter != gap_buffer.cursor_position:
				cursor_position.x += 1
				counter += 1
	text_display.text = current_text
	buffer_display.text = gap_buffer.raw()
	await get_tree().process_frame
	buffer_display.position = text_display.position + Vector2(0, text_display.size.y)
	update_scrollbar()
	update_cursor(cursor_position)
func update_cursor(cursor_position):
	row_column_display.text = str(Vector2(cursor_position))
	cursor.position = text_display.position + Vector2(cursor_position)*character_size

