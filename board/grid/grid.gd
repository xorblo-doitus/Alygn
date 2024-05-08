class_name Grid
extends GridContainer


signal state_changed()
signal matches_changed(matches: Array[TokenLine])


enum State {
	NONE,
	DRAGGABLE,
	DRAGGING,
	SCORING,
	FILLING,
}


@export var rows: int = 5
@export var token_size: Vector2 = Vector2(128, 128):
	set(new):
		token_size = new
		#_token_size_with_margin = token_size + Vector2(
			#get_theme_constant("h_separation"),
			#get_theme_constant("v_separation"),
		#)
@export var minimum_token_alignement: int = 3


var _state: State = State.DRAGGABLE:
	set(new):
		_state = new
		state_changed.emit()

var _player_deck: Array[Token] = Grid._get_default_deck()

# Dragging vars
var _currently_dragged: TokenSprite
var _dragged_global_position: Vector2
var _drag_offset: Vector2
var _swap_screen_pos: Vector2
#var _token_size_with_margin: Vector2


func _ready() -> void:
	_build_sprites()
	
	var grid: Array[Token] = _generate_grid_without_alignement(_player_deck)
	for index in grid.size():
		get_token_sprite(index).token = grid[index]


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
			if _state == State.DRAGGING:
				undrag()
				if _matches_cache:
					scores()


func _build_sprites() -> void:
	for x in columns:
		for y in rows:
			var new_token_sprite: TokenSprite = preload("res://board/grid/token/token_sprite/token_sprite.tscn").instantiate()
			#new_token_sprite.token.randomize_type()
			new_token_sprite.custom_minimum_size = token_size
			new_token_sprite.reset_size()
			new_token_sprite.clicked.connect(_on_token_sprite_clicked.bind(new_token_sprite))
			new_token_sprite.type_changed.connect(check)
			add_child(new_token_sprite)
			new_token_sprite.token = Token.new()



func drag(token_sprite: TokenSprite) -> void:
	if _state != State.DRAGGABLE:
		return
	
	_state = State.DRAGGING
	_currently_dragged = token_sprite
	_swap_screen_pos = get_global_mouse_position()
	_drag_offset = token_sprite.get_visual_screen_position() - get_global_mouse_position()
	token_sprite.dragged = true


func undrag() -> void:
	if _state != State.DRAGGING:
		return
	
	_currently_dragged.dragged = false
	_currently_dragged.reset_visual_screen_position()
	_currently_dragged = null
	
	_state = State.DRAGGABLE


func scores() -> void:
	if _state != State.NONE and _state != State.DRAGGABLE:
		return
	
	_state = State.SCORING
	
	var token_activation_count: Dictionary = {}
	for token_line in _matches_cache:
		for token_sprite in token_line.token_sprites:
			#var token_sprite: TokenSprite = get_token_sprite(index)
			if not token_activation_count.has(token_sprite):
				token_activation_count[token_sprite] = TokenTypeCumulative.new()
			token_activation_count[token_sprite].add(token_line.type)
	
	var activated_tokens: Array[TokenSprite] = []
	for token_line in _matches_cache:
		token_line.scored.emit()
		for token_sprite in token_line.token_sprites:
			#var token_sprite: TokenSprite = get_token_sprite(index)
			if token_sprite not in activated_tokens:
				activated_tokens.push_back(token_sprite)
			token_sprite.scores(Vector2(860, 330), token_line.type)
			token_activation_count[token_sprite].remove(token_line.type)
			token_sprite.token.active_type = token_activation_count[token_sprite].get_type()
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0.5).timeout
	
	for token_sprite in activated_tokens:
		_player_deck.push_back(token_sprite.token)
		token_sprite.fall()
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(0.8).timeout
	
	_state = State.NONE
	refill(activated_tokens, _player_deck)


var refills_without_ghost: int = 3
var _consecutive_refills: int = 0
func refill(sprites: Array[TokenSprite], deck: Array[Token]) -> void:
	if _state != State.NONE and _state != State.DRAGGABLE:
		return
	
	_state = State.FILLING
	_consecutive_refills += 1
	
	if _consecutive_refills > refills_without_ghost:
		for i in min(deck.size() - 1, (_consecutive_refills - refills_without_ghost) ** 2):
			deck[i].temporary_ghostly = true
	deck.shuffle()
	
	for sprite in sprites:
		sprite.token = deck.pop_back()
		sprite.refill()
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(0.6).timeout
	
	check()
	_state = State.DRAGGABLE
	
	if _matches_cache:
		scores()
	else:
		_consecutive_refills = 0
	



func index_to_coord(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(index % columns, index / rows)


func coord_to_index(coord: Vector2i) -> int:
	#if coord.x < 0 or coord.x >= columns or coord.y < 0 or coord.y >= rows:
		#return -1
	
	return coord.x + coord.y * columns


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


var _matches_cache: Array[TokenLine] = []
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
	_matches_cache = matches
	matches_changed.emit(matches)


func update_tokens_active_types(matches: Array[TokenLine]) -> void:
	var active_types: Array[Element.Type] = []
	active_types.resize(columns * rows)
	
	for match_ in matches:
		for token_sprite in match_.token_sprites:
			@warning_ignore("int_as_enum_without_cast")
			active_types[token_sprite.get_index()] |= match_.type
	
	for index in active_types.size():
		get_token_sprite(index).token.active_type = active_types[index]
	#var active_types: Array[Element.Type] = []
	#active_types.resize(columns * rows)
	#
	#for match_ in matches:
		#for index in match_.index:
			#@warning_ignore("int_as_enum_without_cast")
			#active_types[index] |= match_.type
	#
	#for index in active_types.size():
		#get_token_sprite(index).token.active_type = active_types[index]


func check_line(to_check: Array[int], minimum_lenght: int = minimum_token_alignement) -> Array[TokenLine]:
	var result: Array[TokenLine] = []
	var available_types: Array[Element.Type] = []
	available_types.append_array(to_check.map(_index_to_type))
	
	for i_master in len(to_check) - minimum_lenght + 1:
		while available_types[i_master]:
			var line: TokenLine = TokenLine.new([get_token_sprite(to_check[i_master])], available_types[i_master])
			
			for i in range(i_master + 1, len(to_check)):
				var index = to_check[i]
				var type: Element.Type = available_types[i]
				
				if line.type & type:
					@warning_ignore("int_as_enum_without_cast")
					line.type &= type
					line.token_sprites.push_back(get_token_sprite(index))
				else:
					break
			
			for i_to_use in range(i_master, i_master + line.token_sprites.size()):
				@warning_ignore("int_as_enum_without_cast")
				available_types[i_to_use] -= line.type
			
			if line.get_alignement_len() >= minimum_lenght:
				result.push_back(line)
	
	return result


func _index_to_type(index: int) -> Element.Type:
	return get_token_sprite(index).token.type


#func _long_enough(token_line: TokenLine, minimum_lenght: int) -> bool:
	#return token_line.index.size() >= minimum_lenght


func _generate_grid_without_alignement(deck: Array[Token], minimum_lenght: int = minimum_token_alignement) -> Array[Token]:
	var result: Array[Token] = []
	deck.shuffle()
	
	for y in rows:
		for x in columns:
			var discarded: Array[Token] = []
			result.append(_pop_deck(deck))
			while _is_aligned_with_up_left(result, Vector2i(x, y), minimum_lenght):
				discarded.push_back(result.pop_back())
				if deck:
					result.append(_pop_deck(deck))
				else:
					result.push_back(discarded.pop_back().temporary_ghosted())
			deck.append_array(discarded)
	
	return result


func _is_aligned_with_up_left(grid: Array[Token], coord: Vector2i, minimum_lenght: int) -> bool:
	#var base_token: Element.Type = grid[coord_to_index(Vector2i(coord.x, coord.y))]
	#var base_type: Element.Type = base_token.type
	
	# Horizontal
	var type: Element.Type = Element.Type.ANY
	var x: int = coord.x
	var left_to_match: int = minimum_lenght
	
	while x >= 0:
		var token: Token = grid[coord_to_index(Vector2i(x, coord.y))]
		
		@warning_ignore("int_as_enum_without_cast")
		type &= token.type
		
		if not type:
			break
		
		if not token.is_ghostly():
			left_to_match -= 1
		
		if left_to_match == 0:
			return true
		
		x -= 1
	
	# Vertical
	type = Element.Type.ANY
	var y: int = coord.y
	left_to_match = minimum_lenght
	
	while y >= 0:
		var token: Token = grid[coord_to_index(Vector2i(coord.x, y))]
		
		@warning_ignore("int_as_enum_without_cast")
		type &= token.type
		
		if not type:
			break
		
		if not token.is_ghostly():
			left_to_match -= 1
		
		if left_to_match == 0:
			return true
		
		y -= 1
	
	return false

#func _is_aligned(grid: Array[Token], coord: Vector2i, minimum_lenght: int) -> bool:
	## Horizontal
	#for master_x in range(max(0, coord.x - minimum_lenght + 1), min(columns - minimum_lenght, coord.x + 1)):
		#var type: Element.Type = grid[coord_to_index(Vector2i(master_x, coord.y))].type
		#for x in range(master_x + 1, master_x + minimum_lenght):
			#type &= grid[coord_to_index(Vector2i(x, coord.y))].type
		#if type:
			#return true
	#
	## Vertical
	#for master_y in range(max(0, coord.y - minimum_lenght + 1), min(rows - minimum_lenght, coord.y + 1)):
		#var type: Element.Type = grid[coord_to_index(Vector2i(coord.x, master_y))].type
		#for y in range(master_y + 1, master_y + minimum_lenght):
			#type &= grid[coord_to_index(Vector2i(coord.x, y))].type
		#if type:
			#return true
	#
	#return false


func _pop_deck(deck: Array[Token]) -> Token:
	if deck:
		return deck.pop_back()
	#elif discarded:
		#deck.append_array(discarded)
		#discarded.clear()
		#return deck.pop_back()
	else:
		return Token.new()


static func _get_default_deck() -> Array[Token]:
	var result: Array[Token] = []
	
	for __ in 10:
		result.push_back(Token.new(Element.Type.PLANT))
		result.push_back(Token.new(Element.Type.WATER))
		result.push_back(Token.new(Element.Type.FIRE))
	
	for __ in 4:
		result.push_back(Token.new(Element.Type.HEAL))
		
	result.push_back(Token.new(Element.Type.ANY))
	
	return result
