extends Node2D

onready var timer = $Timer
onready var pos = $Position2D

export var sprite = ""
var sprite_list = []
var death_list = []

func _process(delta):
	for sprite in sprite_list:
		if not is_instance_valid(sprite):
			
			print("%s has been freed." % sprite)
			print(sprite_list)
			sprite_list.erase(sprite)
			death_list.append(sprite)
			print(sprite_list)

func _ready():
	var new_sprite = load(sprite).instance()
	add_child(new_sprite)
	new_sprite.position = pos.position
	sprite_list.append(new_sprite)
	timer.start()


func _on_Timer_timeout():
	for sprite in sprite_list:
		sprite.queue_free()
