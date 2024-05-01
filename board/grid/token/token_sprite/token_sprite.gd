class_name Token
extends Control


signal clicked 
signal type_changed


enum Type {
	## Not an ingame type, used as null for static typing.
	NULL,
	PLANT,
	WATER = 1 << 1,
	FIRE = 1 << 2,
	HEAL = 1 << 3,
	ANY = (1 << 4) - 1,
}



const TEXTURE_FOR_TYPE = {
	Type.NULL: null,
	Type.PLANT: preload("res://board/grid/token/token_sprite/sprites/plant.png"),
	Type.WATER: preload("res://board/grid/token/token_sprite/sprites/water.png"),
	Type.FIRE: preload("res://board/grid/token/token_sprite/sprites/fire.png"),
	Type.HEAL: preload("res://board/grid/token/token_sprite/sprites/heal.png"),
}
const COMBINING_TEXTURE_FOR_TYPE = {
	Type.NULL: null,
	Type.PLANT: preload("res://board/grid/token/token_sprite/sprites/combining_plant.png"),
	Type.WATER: preload("res://board/grid/token/token_sprite/sprites/combining_water.png"),
	Type.FIRE: preload("res://board/grid/token/token_sprite/sprites/combining_fire.png"),
	Type.HEAL: preload("res://board/grid/token/token_sprite/sprites/combining_heal.png"),
}


@export var type: Type = Type.NULL:
	set(new):
		type = new
		adapt_visual_to_type()
		type_changed.emit()

var active_type: Type = Type.NULL:
	set(new):
		active_type = new
		adapt_visual_to_type()

var dragged: bool:
	set(new):
		dragged = new
		if dragged:
			visual.z_index = 1
		else:
			visual.z_index = 0

@onready var visual: Control = $Visual
@onready var elements: Control = $Visual/Elements


func _ready() -> void:
	adapt_visual_to_type()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT and OS.is_debug_build():
			randomize_type()


func set_visual_screen_position(screen_position: Vector2) -> void:
	visual.global_position = screen_position


func get_visual_screen_position() -> Vector2:
	return visual.global_position


func reset_visual_screen_position() -> void:
	visual.position = Vector2.ZERO


func get_global_center() -> Vector2:
	return get_global_rect().get_center()


func randomize_type() -> void:
	var new_type: Type = type
	while new_type == type:
		if randf() < 0.1:
			new_type = Type.ANY
		else:
			@warning_ignore("int_as_enum_without_cast")
			new_type = 1 << randi_range(0, 3)
	type = new_type


func adapt_visual_to_type(for_type: Type = type, for_active_types: Type = active_type) -> void:
	if not is_node_ready():
		return
	
	for child in elements.get_children():
		child.queue_free()
	
	if for_type in TEXTURE_FOR_TYPE:
		elements.add_child(preload("res://board/grid/token/token_element.tscn").instantiate().setup(
			for_type,
			for_active_types,
			TEXTURE_FOR_TYPE.get(for_type),
		))
	else:
		for available_type in COMBINING_TEXTURE_FOR_TYPE:
			if for_type & available_type:
				elements.add_child(preload("res://board/grid/token/token_element.tscn").instantiate().setup(
					available_type,
					for_active_types,
					COMBINING_TEXTURE_FOR_TYPE[available_type],
				))
		


static func get_color(for_type: Type) -> Color:
	match for_type:
		Type.PLANT:
			return Color.GREEN
		Type.WATER:
			return Color.BLUE
		Type.FIRE:
			return Color.RED
		Type.HEAL:
			return Color(1, 0.5, 0.5)
		Type.ANY:
			return Color(2, 2, 2)
	
	var result: Color = Color.BLACK
	
	if for_type & Type.PLANT:
		result += Color(0, 1, 0, 0)
	if for_type & Type.WATER:
		result += Color(0, 0, 1, 0)
	if for_type & Type.FIRE:
		result += Color(1, 0, 0, 0)
	if for_type & Type.HEAL:
		result += Color(1, 0.5, 0.5, 0)
	
	return result
