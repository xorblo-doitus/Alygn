class_name TokenLineSprite
extends Line2D


static func instantiate() -> TokenLineSprite:
	return preload("uid://byy6pqqmgc22h").instantiate() #"res://room/board/grid/token_line/token_line_sprite.tscn"


func _init() -> void:
	if OS.is_debug_build() and false:
		width = 32
		width_curve = load("res://room/board/grid/token_line/debug_width.tres")


func set_visuals(token_line: TokenLine) -> void:
	clear_points()
	
	token_line.scored.connect(queue_free)
	
	for token_sprite in token_line.token_sprites:
		add_point(to_local(token_sprite.get_global_center()))
	
	default_color = Element.get_color(token_line.type)
	default_color.a /= 5.0
	#hide()
