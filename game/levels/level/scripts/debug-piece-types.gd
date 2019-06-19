extends Control

# Signals
signal update_labels(labels)

################################################################################
# PRIVATE METHODS
################################################################################

func _process(delta):
	if get_child_count() > 0:
		var labels = get_children()
		
		emit_signal("update_labels", labels)

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

func configure_cell_labels(world_coordinates):
	for coordinate in world_coordinates:
		var label = Label.new()
		
		label.text = "-1"
		label.rect_position = coordinate
		add_child(label)

################################################################################

func deactivate():
	visible = false
	set_process(false)
