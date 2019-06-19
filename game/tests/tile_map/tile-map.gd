extends TileMap

onready var goal = $Goal
onready var current = $Current
onready var target = $Target

func _ready():
	var goal_cell = world_to_map(goal.position)
	var current_cell = world_to_map(current.position)
	var target_cell = world_to_map(target.position)
	var distance = current_cell.distance_to(target_cell)
	
	var thing = Vector2(0, 0)
	var stuff = Vector2(2, 2)
	
	print(lerp(thing, stuff, 0.5))