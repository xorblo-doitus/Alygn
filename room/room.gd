extends Control


@onready var board: Board = $Board
@onready var elemonsters_left: Node2D = $ElemonstersLeft


func _ready() -> void:
	board.grid.scored.connect(_on_token_scored)


func _on_token_scored(token_sprite: TokenSprite, type: Element.Type) -> void:
	for elemonster_sprite: ElemonsterSprite in elemonsters_left.get_children():
		if elemonster_sprite.elemonster_resource.type & type or type == Element.Type.HEAL:
			token_sprite.scores(elemonster_sprite.get_global_token_target(), type)
