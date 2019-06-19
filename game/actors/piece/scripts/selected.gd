extends "res://actors/piece/scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func enter(host):
	host.can_move = true
	host.pointer.activate()
	host.set_process(true)

################################################################################

func handle_input(host, event):
	if event is InputEventMouseButton and host.can_move:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			return 'move'

################################################################################

func update(host, delta):
	match host.last_move:
		'jump':
			host.emit_signal("select_request", host)
			host.last_move == 'none'
		'move':
			host.end_turn = true
			host.emit_signal("move_completed")
			
			return 'idle'
