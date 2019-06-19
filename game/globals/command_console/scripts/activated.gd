extends "res://actors/piece/scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func enter(host):
	host.prompt.focus_mode = Control.FOCUS_ALL
	host.prompt.grab_focus()

################################################################################

func handle_input(host, event):
	if event is InputEventKey:
		if event.scancode == KEY_QUOTELEFT and not event.is_pressed():
			return 'deactivated'
