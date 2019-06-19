extends ColorRect

# Signals
signal show_goal(side_color)

# Child Nodes
onready var _team_label = $VBoxContainer/TeamLabel
onready var _turn_indicator = $VBoxContainer/TurnIndicator
onready var _capture_container = $VBoxContainer/CaptureContainer
onready var _show_goal = $VBoxContainer/ShowGoal

# Attributes
export var side_color = ""

################################################################################
# PRIVATE METHODS
################################################################################

func _configure_capture_container_colors():
	match side_color.to_lower():
		'black':
			_capture_container.configure_pieces('red')
		'red':
			_capture_container.configure_pieces('black')

################################################################################

func _ready():
	_team_label.text = "%s Team" % side_color
	_configure_capture_container_colors()

################################################################################
# PUBLIC METHODS
################################################################################

func add_captured_piece():
	_capture_container.add_captured_piece()

################################################################################

func toggle_turn_indicator():
	_turn_indicator.toggle_indicator()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_ShowGoal_pressed():
	emit_signal("show_goal", side_color.to_lower())
	
	match _show_goal.text:
		"Show Goal Line":
			_show_goal.text = "Hide Goal Line"
		"Hide Goal Line":
			_show_goal.text = "Show Goal Line"
