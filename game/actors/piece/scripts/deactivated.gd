extends "res://actors/piece/scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func enter(host):
	host.collision.disabled = true

################################################################################

func exit(host):
	host.collision.disabled = false
