extends Node

func _ready():
	for number in range(1, 100):
		if number % 2 == 0: 
			continue
		else:
			print(number)
