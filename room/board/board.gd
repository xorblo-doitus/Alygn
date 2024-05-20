class_name Board
extends PanelContainer


@onready var lines: Node2D = %Lines
@onready var grid: Grid = %Grid


func _on_grid_matches_changed(matches: Array[TokenLine]) -> void:
	for child in lines.get_children():
		child.queue_free()
	
	for line in matches:
		var new_line_sprite: TokenLineSprite = TokenLineSprite.instantiate()
		lines.add_child(new_line_sprite)
		new_line_sprite.set_visuals(line)
		new_line_sprite.width = grid.token_size.x + 4


func _on_grid_state_changed() -> void:
	pass
	#if grid._state == Grid.State.SCORING:
		#for child in lines.get_children():
			#child.queue_free()
