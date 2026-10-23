extends Node
## Player settings, saved to user://settings.cfg.

signal setting_changed(key: String, value: bool)

const DEFAULT_PATH := "user://settings.cfg"
const SECTION := "settings"

## Tests point this at a temp file so the real settings aren't touched.
var path: String = DEFAULT_PATH

var romanization: bool = false
var english_subtitles: bool = false


func _ready() -> void:
	load_settings()


func set_romanization(value: bool) -> void:
	_apply("romanization", value)


func set_english_subtitles(value: bool) -> void:
	_apply("english_subtitles", value)


func _apply(key: String, value: bool) -> void:
	if get(key) == value:
		return
	set(key, value)
	save_settings()
	setting_changed.emit(key, value)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "romanization", romanization)
	cfg.set_value(SECTION, "english_subtitles", english_subtitles)
	var err := cfg.save(path)
	if err != OK:
		push_error("Can't save settings to %s (error %d)" % [path, err])


## Missing file or keys fall back to the defaults (both off).
func load_settings() -> void:
	romanization = false
	english_subtitles = false
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return
	romanization = bool(cfg.get_value(SECTION, "romanization", false))
	english_subtitles = bool(cfg.get_value(SECTION, "english_subtitles", false))
