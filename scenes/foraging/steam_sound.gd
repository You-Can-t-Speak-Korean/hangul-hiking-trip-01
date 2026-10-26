extends RefCounted
## The placeholder "tsss" of a decoy's letter vanishing: a short burst of
## high-passed noise with a quick attack and a falling tail, made in code.

const MIX_RATE := 22050
const LENGTH := 0.5     # seconds
const ATTACK := 0.02    # seconds
const DECAY := 7.0      # envelope falls as exp(-DECAY * t)
const VOLUME := 0.35    # of full scale


static func make() -> AudioStreamWAV:
	var count := int(MIX_RATE * LENGTH)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var data := PackedByteArray()
	data.resize(count * 2)
	var previous := 0.0
	for i in count:
		var t := float(i) / MIX_RATE
		var noise := rng.randf_range(-1.0, 1.0)
		var high := (noise - previous) * 0.5  # difference of neighbours: highs only
		previous = noise
		var envelope := minf(t / ATTACK, 1.0) * exp(-DECAY * t)
		data.encode_s16(i * 2, int(clampf(high * envelope * VOLUME, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
