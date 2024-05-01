extends Control


@onready var lines: Node2D = $Lines
@onready var grid: Grid = $VBoxContainer/Grid


func _on_grid_matches_changed(matches: Array[TokenLine]) -> void:
	for child in lines.get_children():
		child.queue_free()
	
	for line in matches:
		var new_line_sprite: TokenLineSprite = preload("res://board/grid/token_line/token_line_sprite.tscn").instantiate()
		lines.add_child(new_line_sprite)
		new_line_sprite.set_visuals(line, grid)
		new_line_sprite.width = grid.token_size.x + 4
