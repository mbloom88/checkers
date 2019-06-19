extends AudioStreamPlayer

################################################################################
# PUBLIC METHODS
################################################################################

func load_music(song):
	"""
	Loads a song to the audio stream.
	"""
	stream = load(song)

################################################################################

func play_music():
	"""
	Plays the currently loaded song in the audio stream.
	"""
	play()

################################################################################

func stop_music():
	"""
	Stops the currently loaded song in the audio stream.
	"""
	stop()
