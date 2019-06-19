extends TileMap

# TileMap
const UP = -1
const DOWN = 1
var used_map_cells = [] setget , get_used_map_cells
var used_world_cells = [] setget , get_used_world_cells

# Actors
enum PIECES {NONE=-1, BLACK, RED}
var _piece_list = []
var _move_directions = {
	'left_up': Vector2(-1, -1),
	'left_down': Vector2(-1, 1),
	'right_up': Vector2(1, -1),
	'right_down': Vector2(1, 1),
}

# Per Round Info
var _movements = {
		'jumpers': [],
		'movers': [],
	}

################################################################################
# PRIVATE METHODS
################################################################################

func _ready():
	_sort_used_cells()

################################################################################

func _sort_used_cells():
	"""
	Determines what cells are in use on the 'TileMap' and saves those
	coordinates as 'map' and 'world' 'Vector2' coordinates.
	"""
	used_map_cells = get_used_cells()
		
	for cell in used_map_cells:
		var world_cell = map_to_world(cell)
		
		used_world_cells.append(world_cell)

################################################################################
# PUBLIC METHODS
################################################################################

func check_if_piece_selectable(requestor):
	"""
	Determines if a 'piece' is selectable for moves.
	
	Returns 'selectable' = 'true' if the part has available moves and can be
	selected.
	"""
	var selectable = false
	
	_movements = scan_board_for_movements(requestor.type)
	
	match requestor.last_move:
		'jump':
			if requestor in _movements['jumpers']:
				selectable = true
		'none':
			if requestor in _movements['jumpers']:
				selectable = true
			elif _movements['jumpers'].empty() and \
				requestor in _movements['movers']:
				
				selectable = true
	
	return selectable

################################################################################

func check_piece_type(target_cell):
	"""
	Checks a 'target_cell' for a playing piece and determines its 'piece_type.'
	
	Returns the 'piece_type' of the playing piece if it exists in the
	'target_cell.'
	"""
	var piece_type = PIECES.NONE
	
	for piece in _piece_list:
		var cell = world_to_map(piece.position)
		
		if cell == target_cell:
			piece_type = piece.type
	
	return piece_type

################################################################################

func update_piece_list(option, piece):
	"""
	Modifies a list of active pieces on the board.
	"""
	match option:
		'add':
			_piece_list.append(piece)
		'remove':
			_piece_list.erase(piece)

################################################################################

func verify_move_target(piece):
	"""
	Verifies if the 'piece' requesting a move to a 'target_cell' can perform 
	a legal move or jump. Non-king black pieces can only move in the +y/(+1)
	direction while non-king red pieces can only move in the -y/(-1) direction.
	
	Returns a 'world' coordinate for the 'piece' to move or jump to and whether
	a 'move,''jump,' or 'none.'
	"""
	var current_cell = world_to_map(piece.position)
	var target_cell = world_to_map(piece.move_target)
	var target_piece_type = check_piece_type(target_cell)
	var tile_type = get_cellv(target_cell)
	var target_distance = stepify(current_cell.distance_to(target_cell), 0.001)
	var y_direction = int(sign(target_cell.y - current_cell.y))

	# Move and jump limits
	var move_limit = stepify(sqrt(pow(1, 2) + pow(1, 2)), 0.001)
	var jump_limit = stepify(sqrt(pow(2, 2) + pow(2, 2)), 0.001)
	
	# Jumped piece check
	var can_jump = false
	var jumped_cell = Vector2()
	
	if target_distance == jump_limit:
		jumped_cell = lerp(current_cell, target_cell, 0.5)
		
		var piece_type_check = check_piece_type(jumped_cell)
		
		match [piece.type, piece_type_check]:
			[PIECES.BLACK, PIECES.RED], [PIECES.RED, PIECES.BLACK]:
				can_jump = true
	
	# Movement decision
	match [
		piece.is_king,
		piece.type,
		y_direction,
		tile_type,
		target_piece_type
	]:
		[false, PIECES.BLACK, DOWN, 1, PIECES.NONE], \
		[true, PIECES.BLACK, DOWN, 1, PIECES.NONE], \
		[true, PIECES.BLACK, UP, 1, PIECES.NONE], \
		[false, PIECES.RED, UP, 1, PIECES.NONE], \
		[true, PIECES.RED, UP, 1, PIECES.NONE], \
		[true, PIECES.RED, DOWN, 1, PIECES.NONE]:
			if target_distance == move_limit:
				return [map_to_world(target_cell) + cell_size / 2, 'move']
			elif can_jump:
				for piece in _piece_list:
					if world_to_map(piece.position) == jumped_cell:
						piece.is_jump_victim = true
						update_piece_list('remove', piece)
				
				return [map_to_world(target_cell) + cell_size / 2, 'jump']
			else:
				return [piece.position, 'none']
		_: # all else
			return [piece.position, 'none']

################################################################################

func scan_board_for_movements(turn_color):
	"""
	Determines the numbers of pieces that can move and/or jump during a colored-
	side's turn.
	
	Starts by looking at diagonal movements for each piece and finshes by 
	checking if each piece can also jump.
	
	Returns a dictionary of jumpers and movers.
	"""
	_movements['jumpers'].clear()
	_movements['movers'].clear()
	
	# Check if pieces on the board can jump.
	for piece in _piece_list:
		var opponents = []
		
		if piece.type != turn_color:
			continue

		for direction in _move_directions.keys():
			var current_cell = world_to_map(piece.position)
			var target_cell = current_cell + _move_directions[direction]
			var target_type = check_piece_type(target_cell)
			var y_direction = int(sign(target_cell.y - current_cell.y))
			
			if not target_cell in used_map_cells:
				continue
			
			match [piece.is_king, piece.type, y_direction]:
				[false, PIECES.RED, UP], \
				[true, PIECES.RED, UP], \
				[true, PIECES.RED, DOWN], \
				[false, PIECES.BLACK, DOWN], \
				[true, PIECES.BLACK, DOWN], \
				[true, PIECES.BLACK, UP]:
					if target_type == PIECES.NONE and \
						not piece in _movements['movers']:
						
						_movements['movers'].append(piece)
					elif not target_type in [PIECES.NONE, turn_color]:
						opponents.append([target_cell, direction])
		
		# If opponents nearby, check for jump movement
		for opponent in opponents:
			var future_jump = opponent[0] + _move_directions[opponent[1]]
			
			if not future_jump in used_map_cells:
				continue
			
			var target_type = check_piece_type(future_jump)
			
			if target_type == PIECES.NONE:
				_movements['jumpers'].append(piece)

	return _movements

################################################################################
# GETTERS
################################################################################

func get_used_map_cells():
	"""
	Provides a map/cell coordinate list for each tile that is occupying the
	'BaseLayer's' TileMap.
	"""
	return used_map_cells

################################################################################

func get_used_world_cells():
	"""
	Provides a world/pixel coordinate list for each tile that is occupying the
	'BaseLayer's' TileMap.
	"""
	return used_world_cells
