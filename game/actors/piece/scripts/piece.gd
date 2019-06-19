extends Sprite

# Signals
signal move_completed
signal move_request(requestor)
signal select_request(requestor)
signal turn_ended

# Child nodes
onready var tween = $Tween
onready var collision = $KinematicBody2D/CollisionShape2D
onready var crown = $KingCrown
onready var pointer = $Pointer
onready var debug_name_label = $Debug/NameLabel

# State machine
var _current_state = null
var states_stack = []

onready var _states_map = {
	'deactivated': $States/Deactivated,
	'idle': $States/Idle,
	'selected': $States/Selected,
	'move': $States/Move,
	'dead': $States/Dead,
}

# Actor
export var move_speed = 0.5
var type = null setget set_entity_type, get_entity_type
var clickable = false
var can_move = false
var move_target = Vector2()
var last_move = 'none' setget , get_last_move
var is_king = false setget , get_is_king
var is_jump_victim = false setget set_is_jump_victim, get_is_jump_victim
var end_turn = false

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name) -> void:
	_current_state.exit(self)
	
	if state_name == 'previous':
		states_stack.pop_front()
	elif state_name in ['move']:
		states_stack.push_front(_states_map[state_name])
	else:
		var new_state = _states_map[state_name]
		states_stack[0] = new_state

	_current_state = states_stack[0]

	if state_name != 'previous':
		_current_state.enter(self)

################################################################################

func _input(event):
	var state_name = _current_state.handle_input(self, event)
	
	if state_name == 'move':
		move_target = get_global_mouse_position()
		_change_state(state_name)

################################################################################

func _process(delta):
	var state_name = _current_state.update(self, delta)
	
	if state_name:
		_change_state(state_name)

################################################################################

func _ready():
	states_stack.push_front($States/Deactivated)
	_current_state = states_stack[0]
	_change_state('deactivated')
	_provide_debug_info()

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	_change_state('idle')

################################################################################

func become_king():
	is_king = true
	crown.visible = true

################################################################################

func deactivate():
	_change_state('deactivated')

################################################################################

func die():
	_change_state('dead')

################################################################################

func end_turn():
	last_move = 'move'

################################################################################

func move(cell, move_type):
	var state_name = _current_state.move(self, cell)
	
	last_move = move_type
	
	if state_name == 'previous':
		_change_state(state_name)

################################################################################

func select():
	if _current_state == _states_map['idle']:
		_change_state('selected')

################################################################################
# GETTERS
################################################################################

func get_entity_type(): # enum
	return type

################################################################################

func get_is_jump_victim():
	return is_jump_victim

################################################################################

func get_is_king(): # bool
	return is_king

################################################################################

func get_last_move(): # string
	return last_move

################################################################################
# SETTERS
################################################################################

func set_entity_type(value): # enum
	type = value

################################################################################

func set_is_jump_victim(value): # bool
	is_jump_victim = value

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
	_current_state.handle_input(self, event)

################################################################################

func _on_KinematicBody2D_mouse_entered():
	clickable = true

################################################################################

func _on_KinematicBody2D_mouse_exited():
	clickable = false

################################################################################

func _on_Tween_tween_completed(object, key):
	if not _current_state.has_method('_on_Tween_tween_completed'):
		return

	var state_name = _current_state._on_Tween_tween_completed(self, object, key)
	
	if state_name:
		_change_state(state_name)

################################################################################
# DEBUG
################################################################################

func _provide_debug_info():
	debug_name_label.text = str(self)
