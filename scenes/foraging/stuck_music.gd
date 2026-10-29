extends RefCounted
## PLACEHOLDER music for the stuck countdown, made in code: no audio files. A
## low drone of two slightly detuned tones that beat slowly, with a few
## sparse, irregular gong-like hits (decaying sines plus a short noise burst)
## over it, in the spirit of slow ritual music. It is not a melody and not taken
## from any recording. It has never been tuned by ear; replace it in the art pass.
##
## The loop is `loop_seconds` long. Every drone frequency is snapped to a whole
## number of cycles per loop, the drone swells once per loop, and the tail of a
## hit near the end wraps round to the start, so the loop has no seam.

const MIX_RATE := 11025
const TAIL := 4.0       # seconds a hit rings
const PEAK := 0.8       # the mix is scaled to this fraction of full scale
## A gong's partials: frequency ratio, level, decay per second.
const PARTIALS := [[1.0, 1.0, 1.1], [2.76, 0.5, 1.8], [5.4, 0.25, 3.0]]
const NOISE_LENGTH := 0.08  # seconds of noise at the front of a hit


## A whole number of cycles per loop, so the drone ends where it began.
static func snapped_hz(hz: float, loop_seconds: float) -> float:
	return maxf(roundf(hz * loop_seconds), 1.0) / loop_seconds


static func sample_count(config: Dictionary) -> int:
	return roundi(float(config["loop_seconds"]) * MIX_RATE)


## The times (seconds from the loop start) of the hits: irregular gaps drawn from
## the data's range with a fixed seed, so every run sounds the same.
static func hit_times(config: Dictionary) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("seed", 1))
	var times: Array[float] = []
	var loop := float(config["loop_seconds"])
	var t := rng.randf_range(float(config["hit_interval_min"]), float(config["hit_interval_max"])) / 2.0
	while t < loop:
		times.append(t)
		t += rng.randf_range(float(config["hit_interval_min"]), float(config["hit_interval_max"]))
	return times


## `config` is foraging.stuck_music.
static func make(config: Dictionary) -> AudioStreamWAV:
	var count := sample_count(config)
	var loop := float(config["loop_seconds"])
	var mix := PackedFloat32Array()
	mix.resize(count)
	var drone_level := float(config["drone_level"])
	var tones: Array[float] = []
	for hz in config["drone_hz"]:
		tones.append(snapped_hz(float(hz), loop))
	tones.append(tones[0] * 2.0)  # a quiet octave above the first tone
	var levels := [1.0, 1.0, 0.25]
	for i in count:
		var t := float(i) / MIX_RATE
		var sum := 0.0
		for k in tones.size():
			sum += levels[k] * sin(TAU * tones[k] * t)
		var swell := 0.75 + 0.25 * sin(TAU * t / loop)
		mix[i] = sum * swell * drone_level / 2.25
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("seed", 1)) + 1
	var hit_hz := float(config["hit_hz"])
	var hit_volume := float(config["hit_volume"])
	for start in hit_times(config):
		var first := roundi(start * MIX_RATE)
		var previous := 0.0
		for n in roundi(TAIL * MIX_RATE):
			var u := float(n) / MIX_RATE
			var tone := 0.0
			for partial in PARTIALS:
				tone += float(partial[1]) * exp(-float(partial[2]) * u) * sin(TAU * hit_hz * float(partial[0]) * u)
			var strike := minf(u / 0.01, 1.0)  # a soft attack, no click
			var value := tone * strike
			if u < NOISE_LENGTH * 4.0:
				previous = lerpf(previous, rng.randf_range(-1.0, 1.0), 0.35)  # dull, low-passed noise
				value += 0.6 * previous * exp(-u / (NOISE_LENGTH / 3.0))
			mix[(first + n) % count] += value * hit_volume / 1.75
	var peak := 0.001
	for sample in mix:
		peak = maxf(peak, absf(sample))
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		data.encode_s16(i * 2, int(clampf(mix[i] / peak * PEAK, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = count
	return stream
