class_name ElemonsterSprite
extends Node2D


@export var elemonster_resource: ElemonsterResource:
	set(new):
		elemonster_resource = new
		update_elemonster_resource()

var monster_height: float = 0.0:
	set(new):
		monster_height = new
		_on_height_changed()


@onready var shadow_sprite: Sprite2D = $Shadow/ShadowSprite
@onready var monster_sprite: Sprite2D = $Monster/MonsterSprite
@onready var shadow: Marker2D = $Shadow
@onready var monster: Marker2D = $Monster
@onready var idle_animation_player: AnimationPlayer = $IdleAnimationPlayer


## Shows that it's powered
var on: bool:
	set(new):
		on = new
		if not (elemonster_resource and is_node_ready()):
			return
		
		monster_sprite.texture = elemonster_resource.on_sprite_texture if on else elemonster_resource.sprite_texture
		idle_animation_player.speed_scale = 3.0 if on else 1.0



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
	idle_animation_player.play(elemonster_resource.animation, -1, randf_range(0.8, 1.2))
	idle_animation_player.advance(randf() * 10.0)


func get_global_token_target() -> Vector2:
	return monster_sprite.global_position #+ monster_sprite.get_rect().size / 2.0


func _on_height_changed() -> void:
	if not is_node_ready():
		return
	
	monster.position.y = -monster_height
	shadow.scale = Vector2(1.0 - monster_height/50.0, 1.0 - monster_height/50.0)
