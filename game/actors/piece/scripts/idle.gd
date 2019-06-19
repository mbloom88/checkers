extends "res://actors/piece/scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func enter(host):
	host.last_move = 'none'
	host.can_move = false
	host.pointer.deactivate()
	host.set_process(false)
	
	if host.end_turn == true:
		host.emit_signal("turn_ended")
		host.end_turn = false

################################################################################

func handle_input(host, event):
	if event is InputEventMouseButton and host.clickable:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			host.emit_signal("select_request", host)
