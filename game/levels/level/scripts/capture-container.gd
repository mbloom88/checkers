extends GridContainer

# Pieces
const ALPHA_FADED = Color(1, 1, 1, 0.1)
const ALPHA_FULL = Color(1, 1, 1, 1)
export var black_texture = ""
export var red_texture = ""

# Capture Info
var captured_pieces = 0 setget , get_captured_pieces

################################################################################
# PUBLIC METHODS
################################################################################

func add_captured_piece():
	captured_pieces += 1
	get_child(captured_pieces - 1).modulate = ALPHA_FULL

################################################################################

func configure_pieces(color):
	for count in range(12):
		var piece = null
		
		match color:
			'black':
				piece = load(black_texture).instance()
			'red':
				piece = load(red_texture).instance()
		
		add_child(piece)
		piece.modulate = ALPHA_FADED

################################################################################
# GETTERS
################################################################################

func get_captured_pieces():
	return captured_pieces
