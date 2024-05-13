class_name TokenSprite
extends Control


signal clicked
signal type_changed


const TEXTURE_FOR_TYPE = {
	Element.Type.NULL: null,
	Element.Type.PLANT: preload("uid://de5dlm7grvf10"),
	Element.Type.WATER: preload("uid://ce83kqme3qbhp"),
	Element.Type.FIRE: preload("uid://dfm33roo0j42u"),
	Element.Type.HEAL: preload("uid://bk5n2bjvxnwyl"),
}
const COMBINING_TEXTURE_FOR_TYPE = {
	Element.Type.NULL: null,
	Element.Type.PLANT: preload("uid://bjprgfslc7qyh"),
	Element.Type.WATER: preload("uid://bfrjc4nksumsu"),
	Element.Type.FIRE: preload("uid://c3j2826yfpecu"),
	Element.Type.HEAL: preload("uid://dgifjcc54ldir"),
}


var token: Token:
	set(new):
		if token:
			token.type_changed.disconnect(_on_token_type_changed)
			token.active_type_changed.disconnect(adapt_visual_to_type)
			token.ghostly_changed.disconnect(adapt_visual_to_ghostly)
		token = new
		if token:
			token.type_changed.connect(_on_token_type_changed)
			token.active_type_changed.connect(adapt_visual_to_type)
			token.ghostly_changed.connect(adapt_visual_to_ghostly)
		
		adapt_visual_to_type()
		adapt_visual_to_ghostly()


var dragged: bool:
	set(new):
		dragged = new
		if dragged:
			visual.z_index = 1
		else:
			visual.z_index = 0

@onready var visual: Control = $Visual
@onready var background: TextureRect = $Visual/Background
@onready var elements: Control = $Visual/Elements
@onready var scoring: Node = $Scoring


static func instantiate() -> TokenSprite:
	return preload("uid://dudx8bxdmsd2f").instantiate() #"res://room/board/grid/token/token_sprite/token_sprite.tscn"


func _ready() -> void:
	adapt_visual_to_type()
	adapt_visual_to_ghostly()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT and OS.is_debug_build():
			token.randomize_type()


func set_visual_screen_position(screen_position: Vector2) -> void:
	visual.global_position = screen_position


func scores(to: Vector2, type: Element.Type, tween_duration: float = 0.5) -> void:
	var scoring_sprite: TokenSprite = TokenSprite.instantiate()
	scoring_sprite.token = Token.new(type, type)
	scoring.add_child(scoring_sprite)
	scoring_sprite.background.texture = preload("uid://r8l2svbvr1qd")
	scoring_sprite.background.modulate = Element.get_color(type)
	scoring_sprite.background.modulate.a /= 4.0
	scoring_sprite.z_index += 2
	
	create_tween().tween_property(
		scoring_sprite,
		"global_position",
		to - size/2,
		tween_duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).finished.connect(scoring_sprite.queue_free)


func fall() -> void:
	visual.z_index = 1
	create_tween().tween_property(
		visual,
		"position:y",
		-128,
		0.25
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).finished.connect(_second_fall_tween.bind(visual.global_position.y + get_viewport_rect().size.y))
	
	create_tween().tween_property(
		visual,
		"global_position:x",
		visual.global_position.x + randf_range(16, 256) * (1 if randf() < 0.5 else -1),
		0.8
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _second_fall_tween(y: float) -> void:
	create_tween().tween_property(
		visual,
		"global_position:y",
		y,
		0.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).finished.connect(_on_fall_finished)


func _on_fall_finished() -> void:
	token.temporary_ghostly = false


func refill() -> void:
	visual.z_index = 0
	visual.position.x = 0
	visual.global_position.y = get_viewport_rect().position.y - visual.size.y
	
	create_tween().tween_property(
		visual,
		"position",
		Vector2.ZERO,
		0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)


func get_visual_screen_position() -> Vector2:
	return visual.global_position


func reset_visual_screen_position() -> void:
	visual.position = Vector2.ZERO


func get_global_center() -> Vector2:
	return get_global_rect().get_center()


func adapt_visual_to_type() -> void:
	if not is_node_ready():
		return
	
	var for_type: Element.Type = token.type if token else Element.Type.NULL
	var for_active_types: Element.Type = token.active_type if token else Element.Type.NULL
	
	for child in elements.get_children():
		child.queue_free()
	
	if for_type in TEXTURE_FOR_TYPE:
		elements.add_child(preload("uid://c4p4q7g2qmp3d").instantiate().setup( #res://board/grid/token/token_sprite/token_element.tscn
			for_type,
			for_active_types,
			TEXTURE_FOR_TYPE.get(for_type),
		))
	else:
		for available_type in COMBINING_TEXTURE_FOR_TYPE:
			if for_type & available_type:
				elements.add_child(preload("uid://c4p4q7g2qmp3d").instantiate().setup( #res://board/grid/token/token_sprite/token_element.tscn
					available_type,
					for_active_types,
					COMBINING_TEXTURE_FOR_TYPE[available_type],
				))


func adapt_visual_to_ghostly() -> void:
	if not is_node_ready():
		return
	
	var ghostly: bool = token.is_ghostly() if token else false
	if ghostly:
		visual.modulate.a = 0.2
	else:
		visual.modulate.a = 1.0


func _on_token_type_changed() -> void:
	adapt_visual_to_type()
	type_changed.emit()
