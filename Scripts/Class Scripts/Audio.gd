extends Node

@export var sound_channels = 32

func _ready():
	#Add sound stream
	var node = Node.new()
	node.name = "SoundChannels"
	add_child(node)
	
	#Add music stream
	node = AudioStreamPlayer.new()
	node.name = "MusicChannel"
	node.bus = "Music"
	add_child(node)
	
	for i in sound_channels:
		node = AudioStreamPlayer.new()
		node.name = "Channel"+str(i)
		node.bus = "Sound Effect"
		$SoundChannels.add_child(node)
		
	print("Initilized " + str(sound_channels) + " Sound channels")

func _physics_process(_delta):
	#loops through all channels
	for i in sound_channels:
		var node = $"SoundChannels".get_node("Channel" +str(i)) 
			

func play_sound(soundID, volume = 1, pitch = 1, channel = -1, overlap = false):
	#Get the channel
	var to_channel = channel
	
	#Look for free channels
	if to_channel == -1:
		#Cycle thru sound channels
		for j in sound_channels:
			var node = $"SoundChannels".get_node("Channel" + str(j))
			if !node.playing:
				to_channel = j
				break
				
			if sound_channels == j:
				to_channel = 0
				break
	
	if(!overlap):
		stop_sound(soundID)
	
	#Play the sound
	var channel_idx = $"SoundChannels".get_node("Channel" +str(to_channel)) 
	channel_idx.stop()
	channel_idx.stream = soundID
	channel_idx.pitch_scale = pitch
	channel_idx.volume_db = volume
	channel_idx.play()
				
func play_music(music):
	$MusicChannel.stream = music
	$MusicChannel.play()

func stop_sound(soundID):
	for j in sound_channels:
		var node = $"SoundChannels".get_node("Channel" + str(j))
		if node.stream == soundID:
			node.stop()
