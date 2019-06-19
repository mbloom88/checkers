extends CanvasLayer

# Child nodes
onready var console = $ConsolePanel
onready var command_log = $ConsolePanel/VBoxContainer/CommandLog
onready var prompt = $ConsolePanel/VBoxContainer/Prompt

# State machine
var _current_state = null
var states_stack = []

onready var _states_map = {
	'deactivated': $States/Deactivated,
	'activated': $States/Activated,
}

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name) -> void:
	_current_state.exit(self)
	
	if state_name == 'previous':
		states_stack.pop_front()
	else:
		var new_state = _states_map[state_name]
		states_stack[0] = new_state

	_current_state = states_stack[0]

	if state_name != 'previous':
		_current_state.enter(self)

################################################################################

func _input(event):
	var state_name = _current_state.handle_input(self, event)
	
	if state_name in ['activated', 'deactivated']:
		_change_state(state_name)

################################################################################

func _ready():
	states_stack.push_front($States/Deactivated)
	_current_state = states_stack[0]
	_change_state('deactivated')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Prompt_text_changed(new_text):
	if new_text == "`":
		prompt.clear()

################################################################################

func _on_Prompt_text_entered(new_text):
	var current_history = command_log.text
	var entered_text = new_text.split(" ")
	var new_log_text = "Invalid command received."
	
	if entered_text.size() == 2:
		match entered_text[0]:
			'debug_mode':
				match entered_text[1]:
					'activate':
						get_tree().call_group("debug", "activate")
						new_log_text = "Debug mode activated."
					'deactivate':
						get_tree().call_group("debug", "deactivate")
						new_log_text = "Debug mode deactivated."
		
	command_log.text = current_history + "\n" + new_log_text
	prompt.clear()
