extends ColorRect

# Child Nodes
onready var _animation = $AnimationPlayer

################################################################################
# PRIVATE METHODS
################################################################################

func _ready():
	deactivate()

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	_animation.play("activated")

################################################################################

func check_animation_status():
	return _animation.assigned_animation

################################################################################

func deactivate():
	_animation.play("deactivated")
