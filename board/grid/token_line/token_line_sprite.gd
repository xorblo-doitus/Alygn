class_name TokenLineSprite
extends Line2D


func _init() -> void:
	if OS.is_debug_build() and false:
		width = 32
		width_curve = load("res://board/grid/token_line/debug_width.tres")


func set_visuals(token_line: TokenLine, grid: Grid) -> void:
	clear_points()
	
	for index in token_line.index:
		add_point(to_local(grid.get_token(index).get_global_center()))
	
	default_color = Token.get_color(token_line.type)
	default_color.a /= 5.0
	#hide()
