extends Node

# Child nodes
onready var _base = $BaseLayer
onready var _black_pieces = $BlackPieces
onready var _red_pieces = $RedPieces
onready var _black_positions = $BlackStartingPositions
onready var _red_positions = $RedStartingPositions
onready var _goals = $Goals
onready var _gui_black_team = $FrontInterface/BlackTeamPanel
onready var _gui_red_team = $FrontInterface/RedTeamPanel
onready var _gui_turn_panel = $FrontInterface/TurnPanel
onready var _announcements = $FrontInterface/Announcements
onready var _debug_cell_vectors = $Debug/CellVectors
onready var _debug_piece_types = $Debug/PieceTypes

# Assets
export var black_piece = ""
export var red_piece = ""
var _number_of_pieces = 12

# Actors
enum PIECES {NONE=-1, BLACK, RED}
var _next_turn = PIECES.NONE

# Internal Info
var _round_count = 1
var _moves_in_turn = {}

# Debug options
export var run_solo = false

################################################################################
# PRIVATE METHODS
################################################################################

func _configure_turn_timer():
	if _moves_in_turn['jumpers'].size() == 1:
		_gui_turn_panel.start_turn_timer(1)
	else:
		_gui_turn_panel.start_turn_timer(5)

################################################################################

func _determine_turn_order():
	match _next_turn:
		PIECES.BLACK:
			_moves_in_turn = _base.scan_board_for_movements(PIECES.BLACK)
			_configure_turn_timer()
			get_tree().call_group("red_pieces", "deactivate")
			get_tree().call_group("black_pieces", "activate")
			_gui_black_team.toggle_turn_indicator()
			_gui_red_team.toggle_turn_indicator()
			_round_count += 1
			_gui_turn_panel.update_round_count(_round_count)
			_next_turn = PIECES.RED
		PIECES.RED:
			_moves_in_turn = _base.scan_board_for_movements(PIECES.RED)
			_configure_turn_timer()
			get_tree().call_group("black_pieces", "deactivate")
			get_tree().call_group("red_pieces", "activate")
			_gui_black_team.toggle_turn_indicator()
			_gui_red_team.toggle_turn_indicator()
			_next_turn = PIECES.BLACK
		PIECES.NONE:
			_gui_turn_panel.update_round_count(_round_count)
			_announcements.start_game()
			yield(_announcements, "game_started")
			_moves_in_turn = _base.scan_board_for_movements(PIECES.BLACK)
			_configure_turn_timer()
			get_tree().call_group("black_pieces", "activate")
			_gui_black_team.toggle_turn_indicator()
			_next_turn = PIECES.RED

################################################################################

func _load_pieces():
	for piece in range (_number_of_pieces):
		var black = load(black_piece).instance()
		var red = load(red_piece).instance()
		
		_black_pieces.add_child(black)
		_red_pieces.add_child(red)
		
		black.position = _black_positions.get_child(piece).position
		red.position = _red_positions.get_child(piece).position
		
		black.type = PIECES.BLACK
		red.type = PIECES.RED
		
		black.connect("move_completed", self, "_on_Piece_move_completed")
		black.connect("move_request", self, "_on_Piece_move_request")
		black.connect("select_request", self, "_on_Piece_select_request")
		black.connect("turn_ended", self, "_on_Piece_turn_ended")
		red.connect("move_completed", self, "_on_Piece_move_completed")
		red.connect("move_request", self, "_on_Piece_move_request")
		red.connect("select_request", self, "_on_Piece_select_request")
		red.connect( "turn_ended", self, "_on_Piece_turn_ended")
		
		_base.update_piece_list('add', black)
		_base.update_piece_list('add', red)
	
	_determine_turn_order()

################################################################################

func _ready():
	_load_pieces()
	_provide_debug_info()

################################################################################

func _select_piece(selected_piece):
	for piece in get_tree().get_nodes_in_group("pieces"):
		if piece != selected_piece and piece.type == selected_piece.type:
			piece.deactivate()
	
	selected_piece.select()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Goals_king_event(king_piece):
	if king_piece.is_king == false:
		king_piece.become_king()

################################################################################

func _on_Piece_move_completed():
	for piece in get_tree().get_nodes_in_group("pieces"):
		if piece.is_jump_victim:
			piece.die()
			
			match piece.type:
				PIECES.BLACK:
					_gui_red_team.add_captured_piece()
				PIECES.RED:
					_gui_black_team.add_captured_piece()
	
################################################################################

func _on_Piece_move_request(piece):
	var move_package = _base.verify_move_target(piece)
	var move_cell = move_package[0]
	var move_type = move_package[1]
	
	piece.move(move_cell, move_type)

################################################################################

func _on_Piece_select_request(piece):
	var selectable = _base.check_if_piece_selectable(piece)
	
	if selectable:
		_select_piece(piece)
	else:
		if piece.can_move:
			piece.end_turn()

################################################################################

func _on_Piece_turn_ended():
	_determine_turn_order()

################################################################################

func _on_TeamPanel_show_goal(color):
	_goals.toggle_goal_visiblity(color)

################################################################################

func _on_TurnPanel_time_is_up():
	pass # Replace with function body.

################################################################################
# DEBUG
################################################################################

func _on_PieceTypes_update_labels(labels):
	for label in labels:
		var label_cell = _base.world_to_map(label.rect_position)
		var piece_type = _base.check_piece_type(label_cell)
		
		label.text = str(piece_type)

################################################################################

func _provide_debug_info():
	# Cell vectors
	var label_info = []
	
	for cell in _base.used_world_cells:
		var label_text = str(_base.world_to_map(cell))
		cell.y += _base.cell_size.y * 0.75
		label_info.append([cell, label_text])
	
	_debug_cell_vectors.configure_cell_labels(label_info) 
	
	# Piece types
	_debug_piece_types.configure_cell_labels(_base.used_world_cells)
