class_name TokenSprite
extends Control


signal clicked
signal type_changed


const TEXTURE_FOR_TYPE = {
	Token.Type.NULL: null,
	Token.Type.PLANT: preload("res://board/grid/token/token_sprite/sprites/plant.png"),
	Token.Type.WATER: preload("res://board/grid/token/token_sprite/sprites/water.png"),
	Token.Type.FIRE: preload("res://board/grid/token/token_sprite/sprites/fire.png"),
	Token.Type.HEAL: preload("res://board/grid/token/token_sprite/sprites/heal.png"),
}
const COMBINING_TEXTURE_FOR_TYPE = {
	Token.Type.NULL: null,
	Token.Type.PLANT: preload("res://board/grid/token/token_sprite/sprites/combining_plant.png"),
	Token.Type.WATER: preload("res://board/grid/token/token_sprite/sprites/combining_water.png"),
	Token.Type.FIRE: preload("res://board/grid/token/token_sprite/sprites/combining_fire.png"),
	Token.Type.HEAL: preload("res://board/grid/token/token_sprite/sprites/combining_heal.png"),
}


var token: Token:
	set(new):
		if token:
			token.type_changed.disconnect(_on_token_type_changed)
			token.active_type_changed.disconnect(adapt_visual_to_type)
		token = new
		if token:
			token.type_changed.connect(_on_token_type_changed)
			token.active_type_changed.connect(adapt_visual_to_type)


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


func _ready() -> void:
	adapt_visual_to_type()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT and OS.is_debug_build():
			token.randomize_type()


func set_visual_screen_position(screen_position: Vector2) -> void:
	visual.global_position = screen_position


func scores(to: Vector2, type: Token.Type, tween_duration: float = 0.5) -> void:
	var scoring_sprite: TokenSprite = preload("res://board/grid/token/token_sprite/token_sprite.tscn").instantiate()
	scoring_sprite.token = Token.new(type, type)
	scoring.add_child(scoring_sprite)
	scoring_sprite.background.texture = preload("res://board/grid/token/token_sprite/sprites/scoring_background.png")
	scoring_sprite.background.modulate = Token.get_color(type)
	scoring_sprite.background.modulate.a /= 4.0
	scoring_sprite.z_index += 2
	
	create_tween().tween_property(
		scoring_sprite,
		"global_position",
		to,
		tween_duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).finished.connect(scoring_sprite.queue_free)


func fall() -> void:
	create_tween().tween_property(
		visual,
		"global_position:y",
		get_viewport_rect().end.y,
		0.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	create_tween().tween_property(
		visual,
		"global_position:x",
		visual.global_position.x + randf_range(-256, 256),
		0.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)


func refill() -> void:
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


func adapt_visual_to_type(
	for_type: Token.Type = token.type,
	for_active_types: Token.Type = token.active_type
) -> void:
	if not is_node_ready():
		return
	
	for child in elements.get_children():
		child.queue_free()
	
	if for_type in TEXTURE_FOR_TYPE:
		elements.add_child(preload("res://board/grid/token/token_sprite/token_element.tscn").instantiate().setup(
			for_type,
			for_active_types,
			TEXTURE_FOR_TYPE.get(for_type),
		))
	else:
		for available_type in COMBINING_TEXTURE_FOR_TYPE:
			if for_type & available_type:
				elements.add_child(preload("res://board/grid/token/token_sprite/token_element.tscn").instantiate().setup(
					available_type,
					for_active_types,
					COMBINING_TEXTURE_FOR_TYPE[available_type],
				))
		

func _on_token_type_changed() -> void:
	adapt_visual_to_type()
	type_changed.emit()
