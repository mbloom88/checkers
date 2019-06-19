extends Control

# Signals
signal game_started

# Child Nodes
onready var _animation = $AnimationPlayer

################################################################################
# PRIVATE METHODS
################################################################################

func _ready():
	_animation.play("idle")

################################################################################
# PUBLIC METHODS
################################################################################

func start_game():
	_animation.play("ready-play-on")

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"ready-play-on":
			_animation.play("idle")
			emit_signal("game_started")
