class_name TokenLine
extends RefCounted


signal scored


var token_sprites: Array[TokenSprite] = []
#var index: Array[int] = []
var type: Token.Type = Token.Type.NULL


func _init(i_token_sprites: Array[TokenSprite] = token_sprites, i_type: Token.Type = Token.Type.NULL) -> void:
	token_sprites = i_token_sprites
	type = i_type


func _to_string() -> String:
	return "TokenLine(%s)[%s]" % [Token.Type.find_key(type), get_indexes()]


func get_indexes() -> Array[int]:
	var result: Array[int] = []
	
	for token_sprite in token_sprites:
		result.push_back(token_sprite.get_index())
		
	return result


## Returns the len of this line, excluding ghostly tokens for exemple.
func get_alignement_len() -> int:
	var lenght: int = 0
	
	for token_sprite in token_sprites:
		if not token_sprite.token.is_ghostly():
			lenght += 1
	
	return lenght
