class_name Grid
extends GridContainer


signal matches_changed(matches: Array[TokenLine])


@export var rows: int = 5
@export var token_size: Vector2 = Vector2(128, 128):
	set(new):
		token_size = new
		_token_size_with_margin = token_size + Vector2(
			get_theme_constant("h_separation"),
			get_theme_constant("v_separation"),
		)
@export var minimum_token_alignement: int = 3


var _currently_dragged: TokenSprite
var _dragged_global_position: Vector2
var _drag_offset: Vector2
var _swap_screen_pos: Vector2
var _token_size_with_margin: Vector2


func _ready() -> void:
	for x in columns:
		for y in rows:
			var new_token_sprite: TokenSprite = preload("res://board/grid/token/token_sprite/token_sprite.tscn").instantiate()
			new_token_sprite.token = Token.new()
			new_token_sprite.token.randomize_type()
			new_token_sprite.custom_minimum_size = token_size
			new_token_sprite.reset_size()
			new_token_sprite.clicked.connect(_on_token_sprite_clicked.bind(new_token_sprite))
			new_token_sprite.type_changed.connect(check)
			add_child(new_token_sprite)


func _on_token_sprite_clicked(token_sprite: TokenSprite) -> void:
	drag(token_sprite)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _currently_dragged:
			var delta: Vector2 = event.global_position - _swap_screen_pos
			
			while true:
				var target: Vector2i = Vector2(
					_delta_float_to_int(delta.x, (token_size.x + get_theme_constant("h_separation")) / 1.9),
					_delta_float_to_int(delta.y, (token_size.y + get_theme_constant("v_separation")) / 1.9),
				)
				
				if target == Vector2i.ZERO:
					break
				
				var swap_with: TokenSprite = get_token_sprite_at(get_token_sprite_pos(_currently_dragged) + target)
				
				if swap_with == null:
					break
				
				swap(_currently_dragged, swap_with)
				
				var to_remove: Vector2 = Vector2(
					target.x * (token_size.x + get_theme_constant("h_separation")),
					target.y * (token_size.y + get_theme_constant("v_separation")),
				)
				
				delta -= to_remove
				_swap_screen_pos += to_remove
			_dragged_global_position = event.global_position + _drag_offset
			_currently_dragged.set_visual_screen_position(_dragged_global_position)
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			undrag()


func drag(token_sprite: TokenSprite) -> void:
	if _currently_dragged:
		return
	
	_currently_dragged = token_sprite
	_swap_screen_pos = get_global_mouse_position()
	_drag_offset = token_sprite.get_visual_screen_position() - get_global_mouse_position()
	token_sprite.dragged = true


func undrag() -> void:
	if _currently_dragged == null:
		return
	
	_currently_dragged.dragged = false
	_currently_dragged.reset_visual_screen_position()
	_currently_dragged = null


func get_token_sprite_at(pos: Vector2i) -> TokenSprite:
	if pos.x < 0 or pos.x >= columns or pos.y < 0 or pos.y >= rows:
		return null
	
	return get_child(pos.x + pos.y * columns)


func get_token_sprite(index: int) -> TokenSprite:
	return get_child(index)


func get_token_sprite_pos(token_sprite: TokenSprite) -> Vector2i:
	var index: int = token_sprite.get_index()
	@warning_ignore("integer_division")
	return Vector2i(index % columns, index / rows)


func swap(a: TokenSprite, b: TokenSprite) -> void:
	var a_i: int = a.get_index()
	var b_i: int = b.get_index()
	
	move_child(a, b_i)
	move_child(b, a_i)


func _delta_float_to_int(delta: float, ceiling: float) -> int:
	if delta > ceiling:
		return 1
	
	if -delta > ceiling:
		return -1
	
	return 0


func _on_sort_children() -> void:
	if _currently_dragged:
		_currently_dragged.set_visual_screen_position(_dragged_global_position)
	check()


func check() -> void:
	var matches: Array[TokenLine] = []
	
	# Horizontal
	for y in range(0, rows * columns, columns):
		var index: Array[int] = []
		index.append_array(range(y, y + columns))
		#print(index)
		matches.append_array(check_line(index))
		
	# Vertical
	for x in columns:
		var index: Array[int] = []
		index.append_array(range(x, x + rows * columns, columns))
		#print(index)
		matches.append_array(check_line(index))
	
	update_tokens_active_types(matches)
	matches_changed.emit(matches)


func update_tokens_active_types(matches: Array[TokenLine]) -> void:
	var active_types: Array[Token.Type] = []
	active_types.resize(columns * rows)
	
	for match_ in matches:
		for index in match_.index:
			@warning_ignore("int_as_enum_without_cast")
			active_types[index] |= match_.type
	
	for index in active_types.size():
		get_token_sprite(index).token.active_type = active_types[index]


func check_line(to_check: Array[int], minimum_lenght: int = minimum_token_alignement) -> Array[TokenLine]:
	var result: Array[TokenLine] = []
	var available_types: Array[Token.Type] = []
	available_types.append_array(to_check.map(_index_to_type))
	
	for i_master in len(to_check) - minimum_lenght + 1:
		while available_types[i_master]:
			var line: TokenLine = TokenLine.new([to_check[i_master]], available_types[i_master])
			
			for i in range(i_master + 1, len(to_check)):
				var index = to_check[i]
				var type: Token.Type = available_types[i]
				
				if line.type & type:
					@warning_ignore("int_as_enum_without_cast")
					line.type &= type
					line.index.push_back(index)
				else:
					break
			
			for i_to_use in range(i_master, i_master + line.index.size()):
				@warning_ignore("int_as_enum_without_cast")
				available_types[i_to_use] -= line.type
			
			if line.index.size() >= minimum_lenght:
				result.push_back(line)
	
	return result

#
#
#func check_line(to_check: Array[int], minimum_lenght: int = minimum_token_alignement) -> Array[TokenLine]:
	#var result: Array[TokenLine] = []
	#var available_types: Array[Token.Type] = []
	#available_types.append_array(to_check.map(_index_to_type))
	#
	#for i_master in len(to_check) - minimum_lenght + 1:
		#var line: TokenLine = TokenLine.new([], available_types[i_master])
		#
		#for i in range(i_master, len(to_check)):
			#var index = to_check[i]
			#var type: Token.Type = available_types[i]
			#
			#if line.type & type:
				#@warning_ignore("int_as_enum_without_cast")
				#line.type &= type
				#line.index.push_back(index)
			#else:
				#break
				##if result:
					##if len(result[-1].index) < minimum_lenght:
						##result.pop_back()
					##else:
						##for i_to_use in range(i - len(result[-1].index) + 1, i + 1):
							##@warning_ignore("int_as_enum_without_cast")
							##available_types[i_to_use] &= result[-1].type
				###result.push_back(TokenLine.new(range(i - rematches + 1, i)))
				##result.push_back(TokenLine.new([index], type))
				##if first_less_restrictive_i != -1:
					##print(first_less_restrictive_i)
					##i = first_less_restrictive_i - 1
					##first_less_restrictive_i = -1
				##rematches = 0
			#
			##last_type = type
		#
		#if line.index.size() >= minimum_lenght:
			#for i_to_use in range(i_master, i_master + line.index.size()):
				#@warning_ignore("int_as_enum_without_cast")
				#available_types[i_to_use] -= line.type
			#result.push_back(line)
	#
	##if result and len(result[-1].index) < minimum_lenght:
		##result.pop_back()
	#
	#return result


#func check_line(to_check: Array[int], minimum_lenght: int = minimum_token_alignement) -> Array[TokenLine]:
	#var result: Array[TokenLine] = [TokenLine.new([])]
	#var available_types: Array[Token.Type] = []
	#available_types.append_array(to_check.map(_index_to_type))
	#var i: int = 0
	##var start_line_type: Token.Type
	#var first_less_restrictive_i: int = -1
	##var last_type: Token.Type = Token.Type.NULL
	##var rematches: int = 0
	#
	#while i < len(to_check):
		#var index = to_check[i]
		##var token: Token = get_child(index)
		#var type: Token.Type = available_types[i]
		#
		#if result and result[-1].type & type:
			#if type != result[-1].type and first_less_restrictive_i == -1:
				#first_less_restrictive_i = i
			#@warning_ignore("int_as_enum_without_cast")
			#result[-1].type &= type
			#@warning_ignore("int_as_enum_without_cast")
			#result[-1].index.push_back(index)
			##rematches += 1
		#else:
			#if result:
				#if len(result[-1].index) < minimum_lenght:
					#result.pop_back()
				#else:
					#for i_to_use in range(i - len(result[-1].index) + 1, i + 1):
						#@warning_ignore("int_as_enum_without_cast")
						#available_types[i_to_use] &= result[-1].type
			##result.push_back(TokenLine.new(range(i - rematches + 1, i)))
			#result.push_back(TokenLine.new([index], type))
			#if first_less_restrictive_i != -1:
				#print(first_less_restrictive_i)
				#i = first_less_restrictive_i - 1
				#first_less_restrictive_i = -1
			##rematches = 0
		#
		##last_type = type
		#i += 1
	#
	##if result and len(result[-1].index) < minimum_lenght:
		##result.pop_back()
	#
	#return result.filter(_long_enough.bind(minimum_lenght))



#func check_line(to_check: Array[int], minimum_lenght: int = minimum_token_alignement) -> Array[TokenLine]:
	#var result: Array[TokenLine] = [TokenLine.new([])]
	#var i: int = 0
	#var start_line_type: Token.Type
	#var first_less_restrictive_i: int = -1
	##var last_type: Token.Type = Token.Type.NULL
	##var rematches: int = 0
	#
	#while i < len(to_check):
		#var index = to_check[i]
		#var token: Token = get_child(index)
		#
		#if result and result[-1].type & token.type:
			#if token.type != result[-1].type and first_less_restrictive_i != -1:
				#first_less_restrictive_i = i
			#result[-1].type &= token.type
			#@warning_ignore("int_as_enum_without_cast")
			#result[-1].index.push_back(index)
			##rematches += 1
		#else:
			##if result and len(result[-1].index) < minimum_lenght:
				##result.pop_back()
			##result.push_back(TokenLine.new(range(i - rematches + 1, i)))
			#result.push_back(TokenLine.new([index], token.type))
			#if first_less_restrictive_i != -1:
				#i = first_less_restrictive_i - 1
			##rematches = 0
		#
		##last_type = token.type
		#i += 1
	#
	##if result and len(result[-1].index) < minimum_lenght:
		##result.pop_back()
	#
	#return result.filter(_long_enough.bind(minimum_lenght))

func _index_to_type(index: int) -> Token.Type:
	return get_token_sprite(index).token.type


func _long_enough(token_line: TokenLine, minimum_lenght: int) -> bool:
	return token_line.index.size() >= minimum_lenght
