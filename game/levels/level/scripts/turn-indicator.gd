extends TextureRect

# Child Nodes
onready var _animation = $AnimationPlayer

# Assets
export var grey_light = ""
export var green_light = ""

################################################################################
# PRIVATE METHODS
################################################################################

func _load_light(color):
	var light = null
	
	match color:
		'grey':
			light = load(grey_light)
		'green':
			light = load(green_light)
	
	texture = light

################################################################################

func _ready():
	deactivate()

################################################################################

func activate():
	_animation.play("activated")

################################################################################

func deactivate():
	_animation.play("deactivated")


func toggle_indicator():
	if _animation.assigned_animation == 'deactivated':
		_animation.play("activated")
	else:
		_animation.play("deactivated")
