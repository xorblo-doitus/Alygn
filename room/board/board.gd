class_name Board
extends PanelContainer


signal activated_types_changed(types: Element.Type)


@onready var lines: Node2D = %Lines
@onready var grid: Grid = %Grid


func _on_grid_matches_changed(matches: Array[TokenLine]) -> void:
	for child in lines.get_children():
		child.queue_free()
	
	@warning_ignore("int_as_enum_without_cast")
	var activated_types: Element.Type = 0
	for line in matches:
		var new_line_sprite: TokenLineSprite = TokenLineSprite.instantiate()
		lines.add_child(new_line_sprite)
		new_line_sprite.set_visuals(line)
		new_line_sprite.width = grid.token_size.x + 4
		@warning_ignore("int_as_enum_without_cast")
		activated_types |= line.type
	
	activated_types_changed.emit(activated_types)


func _on_grid_state_changed() -> void:
	pass
	#if grid._state == Grid.State.SCORING:
		#for child in lines.get_children():
			#child.queue_free()
