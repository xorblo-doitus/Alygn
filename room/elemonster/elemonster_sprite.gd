class_name ElemonsterSprite
extends Node2D


@export var elemonster_resource: ElemonsterResource:
	set(new):
		elemonster_resource = new
		update_elemonster_resource()


@onready var shadow_sprite: Sprite2D = $Shadow/ShadowSprite
@onready var monster_sprite: Sprite2D = $Monster/MonsterSprite


func _ready() -> void:
	update_elemonster_resource()


func update_elemonster_resource() -> void:
	update_sprite()
	update_shadow()


func update_shadow() -> void:
	if not is_node_ready():
		return
	
	shadow_sprite.modulate = elemonster_resource.shadow_color
	shadow_sprite.texture = elemonster_resource.shadow_texture
	shadow_sprite.scale = elemonster_resource.shadow_size


func update_sprite() -> void:
	if not is_node_ready():
		return
	
	monster_sprite.texture = elemonster_resource.sprite_texture
	monster_sprite.position.y = 16 - elemonster_resource.sprite_texture.get_size().y/2.0


func get_global_token_target() -> Vector2:
	return monster_sprite.global_position #+ monster_sprite.get_rect().size / 2.0
