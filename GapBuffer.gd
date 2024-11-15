extends Node
class_name GapBuffer

var buffer := []
var max_gap_size := 10
var buffer_size := max_gap_size
var cursor_position := 0
var right_start := max_gap_size-1
var right_end := right_start
var gap_size := max_gap_size

func _init():
	buffer.resize(buffer_size)

func resize():
	buffer_size += max_gap_size
	buffer.resize(buffer_size)
	
	gap_size = max_gap_size
	shift_to_end()
func end_of_text():
	return buffer_size - gap_size

func move_cursor(amount):
	if cursor_position + amount < 0 or cursor_position + amount > end_of_text():
		return false
	cursor_position += amount
	if amount < 0:
		buffer[right_start] = buffer[cursor_position]
		buffer[cursor_position] = null
		right_start -= 1
	else:
		right_start += 1
		buffer[cursor_position-1] = buffer[right_start]
		buffer[right_start] = null
	return true
func set_cursor(new_cursor_position):
	if cursor_position > new_cursor_position:
		for i in range(cursor_position-1, new_cursor_position-1, -1):
			buffer[right_start] = buffer[i]
			buffer[i] = null
			right_start -= 1
	elif new_cursor_position > cursor_position:
		for i in range(cursor_position+gap_size, new_cursor_position+gap_size):
			buffer[right_start-gap_size+1] = buffer[i]
			buffer[i] = null
			right_start += 1
	cursor_position = new_cursor_position
		
func shift_to_end():
	var j = 1
	for i in range(right_end, right_start, -1):
		buffer[buffer_size-j]=buffer[i]
		buffer[i] = null
		j+=1
	right_start += max_gap_size
	right_end = buffer_size - 1
	
func move_and_resize_cursor(amount):
	cursor_position += amount
	if gap_size == 0:
		resize()

func insert(c):
	buffer[cursor_position] = c
	gap_size -= 1
	move_and_resize_cursor(1)

func backspace():
	if cursor_position == 0:
		return
	buffer[cursor_position-1] = null
	gap_size += 1
	move_and_resize_cursor(-1)

func delete():
	if cursor_position == end_of_text():
		return
	buffer[right_start+1] = null
	right_start += 1
	gap_size += 1

func pretty():
	var s = ""
	for i in buffer_size:
		if buffer[i] != null: s += buffer[i]
	return s
func raw():
	var s = ""
	for i in buffer_size:
		if buffer[i] == null: s += "_"
		elif buffer[i] == '\n': s += '/'
		else: s += buffer[i]
	s[cursor_position] = "#"
	return s
