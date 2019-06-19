extends VBoxContainer

# Signals
signal time_is_up

# Child Nodes
onready var _round_count = $RoundCountLabel
onready var _timer_label = $TimerLabel
onready var _timer = $Timer

# Internal Info
var time = [0, 0] # minutes, seconds

################################################################################
# PUBLIC METHODS
################################################################################

func start_turn_timer(time_type):
	_timer.stop()
	
	match time_type:
		1:
			time = [1, 0]
			_timer_label.text = "0%d:0%d" % time
			_timer.start()
		5:
			time = [5, 0]
			_timer_label.text = "0%d:0%d" % time
			_timer.start()

################################################################################

func update_round_count(count):
	_round_count.text = "Round %d of 50" % count

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Timer_timeout():
	if time[1] == 0:
		time[0] -= 1
		time[1] = 59
	else:
		time[1] -= 1
	
	if time[1] > 9:
		_timer_label.text = "0%d:%d" % time
	else:
		_timer_label.text = "0%d:0%d" % time
	
	if time[0] == 0 and time[1] == 0:
		emit_signal("time_is_up")
