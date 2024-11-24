extends Node2D

@export var stage_width = 1280
@export var stage_height = 720
@export var stage_music : AudioStream

func _ready():
	Audio.play_music(stage_music)
