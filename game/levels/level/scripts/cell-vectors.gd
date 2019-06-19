extends Control

################################################################################
# PRIVATE METHODS
################################################################################

func _ready():
	deactivate()

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	visible = true
	set_process(true)

################################################################################

func configure_cell_labels(label_info):
	for info in label_info:
		var label = Label.new()
		
		label.rect_position = info[0]
		label.text = info[1]
		add_child(label)

################################################################################

func deactivate():
	visible = false
	set_process(false)
