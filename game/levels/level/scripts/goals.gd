extends Node2D

# Child Nodes
onready var _black_goal = $Black/BlackGoalColor
onready var _red_goal = $Red/RedGoalColor

# Signals
signal king_event(piece)

################################################################################
# PUBLIC METHODS
################################################################################

func toggle_goal_visiblity(color):
	match color:
		'black':
			if _black_goal.check_animation_status() == 'deactivated':
				_black_goal.activate()
			else:
				_black_goal.deactivate()
		'red':
			if _red_goal.check_animation_status() == 'deactivated':
				_red_goal.activate()
			else:
				_red_goal.deactivate()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Black_body_entered(body):
	emit_signal("king_event", body.get_parent())

################################################################################

func _on_Red_body_entered(body):
	emit_signal("king_event", body.get_parent())
