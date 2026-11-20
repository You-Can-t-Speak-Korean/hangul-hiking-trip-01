extends Node
## The placeholder countdown music's player (StuckMusic makes the stream), shared by the foraging
## and animal scenes for the stuck and downed countdowns (data: foraging.stuck_music). Starts at
## volume_db and fades in over fade_seconds; the stream is built on first use. The calls to the
## audio player are skipped headless; the counters still count.

const StuckMusic := preload("res://scenes/foraging/stuck_music.gd")

## Whether it is meant to be playing, how many times it started and stopped, how many calls
## reached the audio player, and whether it is held still (a menu is open).
var playing := false
var silenced := false
var starts := 0
var stops := 0
var audio_calls := 0
var config: Dictionary = {}
var stream: AudioStreamWAV
var player: AudioStreamPlayer
var tween: Tween


func setup(music_config: Dictionary) -> void:
	name = "CountdownMusic"
	config = music_config


func start() -> void:
	if playing:
		return
	playing = true
	starts += 1
	if DisplayServer.get_name() == "headless":
		return
	if stream == null:
		stream = StuckMusic.make(config)
	player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -80.0
	player.process_mode = Node.PROCESS_MODE_ALWAYS  # it plays under the spelling view
	add_child(player)
	player.play()
	tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(player, "volume_db", float(config["volume_db"]), float(config["fade_seconds"]))
	audio_calls += 1


func stop() -> void:
	if not playing:
		return
	playing = false
	silenced = false
	stops += 1
	if player == null:
		return
	if tween != null and tween.is_valid():
		tween.kill()
	player.stop()
	player.queue_free()
	player = null
	audio_calls += 1


## Holds the music still (its position and fade stay where they were) or lets it go on.
func silence(hold: bool) -> void:
	silenced = hold and playing
	if player == null:
		return
	player.stream_paused = hold
	if tween != null and tween.is_valid():
		if hold:
			tween.pause()
		else:
			tween.play()
	audio_calls += 1
