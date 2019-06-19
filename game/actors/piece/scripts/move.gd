extends "res://actors/piece/scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func enter(host):
	host.emit_signal("move_request", host)

################################################################################

func move(host, cell):
	if host.position != cell:
		host.z_index = 1
		host.tween.interpolate_property(
			host,
			"position",
			host.position, 
			cell,
			host.move_speed,
			Tween.TRANS_LINEAR,
			 Tween.EASE_IN_OUT)
		
		host.tween.start()
	else:
		return 'previous'

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Tween_tween_completed(host, object, key):
	host.emit_signal("move_completed")
	host.z_index = 0
	
	return 'previous'
