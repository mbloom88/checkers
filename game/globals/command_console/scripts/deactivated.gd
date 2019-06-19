extends "res://actors/piece/scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func enter(host):
	host.console.visible = false
	host.prompt.focus_mode = Control.FOCUS_NONE

################################################################################

func exit(host):
	host.console.visible = true

################################################################################

func handle_input(host, event):
	if event is InputEventKey:
		if event.scancode == KEY_QUOTELEFT and not event.is_pressed():
			return 'activated'
