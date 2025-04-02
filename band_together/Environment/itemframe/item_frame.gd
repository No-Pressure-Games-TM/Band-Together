extends Sprite2D

@export var show_baton: bool = false
@export var show_drum: bool = false
@export var show_sax: bool = false
@export var show_violin: bool = false

func _ready():
	if show_baton:
		$Baton.visible = true
	elif show_drum:
		$Drum.visible = true
	elif show_sax:
		$Sax.visible = true
	elif show_violin:
		$Violin.visible = true
