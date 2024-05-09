class_name ElemonsterResource
extends Resource


@export_group("sprite")
@export var sprite_texture: Texture2D = preload("res://elemonster/sprites/bush.png")

@export_group("shadow")
@export var shadow_color: Color = Color.BLACK
@export var shadow_size: Vector2 = Vector2(1, 0.4)
@export var shadow_texture: Texture2D = preload("res://elemonster/shadows/circle.svg")
