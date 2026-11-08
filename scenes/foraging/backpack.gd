extends RefCounted
## Fernanda's backpack panel, with no nodes: whether it is open, which elixir row
## is selected, who is being asked to drink it, and what a key or Esc does. The map
## decides whether it may open (`allowed`) and does the pausing; the HUD draws the
## contents of GameState.inventory and this state. Only rows whose item has kind
## "elixir" or "notebook" can be selected; everything else stays view-only. An
## elixir asks who drinks it; the notebook row opens the 수첩 view in the panel
## (`notebook_open`). The 수첩 can also be opened straight from the map by a quick
## key (`open_notebook_quick`); then the panel is open with the notebook showing
## and no list behind it.
##
##   select(id, items) / key(action, items)     the selection (mouse and keyboard)
##   open_choice() / cancel_choice()            the "who drinks" question
##   drink(inventory, traveler) -> Dictionary   one elixir gone, the traveler healed
##   escape() -> String                         "cancel_choice", "close_notebook", "close" or ""
##   reset()                                    selection, choice and message forgotten

const NotebookLogic := preload("res://scenes/foraging/notebook.gd")

## The travelers the choice offers, in button order.
const CHOICES: Array[String] = ["nestor", "fernanda"]

var is_open := false
## True while the 수첩 view is showing in the panel (is_open is true too).
var notebook_open := false
## True when the notebook was opened by a quick key (no list behind it), and the
## input action that opened it: only that key closes it again, and the backpack
## keys do nothing meanwhile.
var notebook_quick := false
var notebook_key := ""
## The notebook's pages (see NotebookLogic).
var book := NotebookLogic.new()
## Item id of the selected row ("" if none).
var selected := ""
## True while the "who drinks" question is up.
var choosing := false
## Which of CHOICES is highlighted in the question.
var choice := 0
## The latest result line and how long it stays (the HUD ticks it).
var message := ""
var message_left := 0.0
## True when the latest message was a wasted drink (the HUD colours it).
var message_wasted := false

var _row := 0  # where the selected row was in the item list, to find its neighbour when it goes


## Opens it. False if `allowed` is false (the map says so) or it is open already.
func open(allowed: bool) -> bool:
	if not allowed or is_open:
		return false
	is_open = true
	return true


## Closes it and forgets the selection, the question and the message. False if it
## was not open.
func close() -> bool:
	if not is_open:
		return false
	is_open = false
	reset()
	return true


## Forgets the selection, the question and the message (the scene restarted).
func reset() -> void:
	notebook_open = false
	notebook_quick = false
	notebook_key = ""
	selected = ""
	choosing = false
	choice = 0
	message = ""
	message_left = 0.0
	message_wasted = false
	_row = 0


## A backpack key. Closed: opens it if `allowed` ("open"). Open: closes it
## ("close"), allowed or not, except over a notebook opened by a quick key, which
## the backpack keys leave alone. "" if nothing happened.
func toggle(allowed: bool) -> String:
	if is_open and notebook_quick:
		return ""
	if is_open:
		close()
		return "close"
	return "open" if open(allowed) else ""


## Esc. One Esc does one thing: with the question up it cancels the question and
## keeps the selection ("cancel_choice"); in the notebook opened from the list it
## goes back to the list ("close_notebook"); otherwise it closes the backpack
## ("close"), a quick-key notebook included; closed it does nothing ("", the map's
## own Esc opens the pause menu).
func escape() -> String:
	if choosing:
		cancel_choice()
		return "cancel_choice"
	if notebook_open and not notebook_quick:
		notebook_open = false
		return "close_notebook"
	return "close" if close() else ""


## True for an item that can be selected: an elixir or the notebook.
static func is_selectable(item_id: String) -> bool:
	return is_elixir(item_id) or is_notebook(item_id)


static func is_elixir(item_id: String) -> bool:
	return Content.has_item(item_id) and String(Content.item(item_id).get("kind", "")) == "elixir"


static func is_notebook(item_id: String) -> bool:
	return Content.has_item(item_id) and String(Content.item(item_id).get("kind", "")) == "notebook"


## Shows the 수첩 in the open panel, from the list (the notebook row was chosen).
## False if the panel is closed, the question is up or the notebook is showing.
func show_notebook(items: Array) -> bool:
	if not is_open or choosing or notebook_open:
		return false
	notebook_open = true
	notebook_quick = false
	notebook_key = ""
	book.open(items)
	return true


## Opens the panel on the 수첩 straight away, for the quick key `action`. False if
## `allowed` is false or the panel is open already.
func open_notebook_quick(allowed: bool, action: String, items: Array) -> bool:
	if not open(allowed):
		return false
	notebook_open = true
	notebook_quick = true
	notebook_key = action
	book.open(items)
	return true


## The ids of the selectable rows of `items` (Inventory.items()), in row order.
static func selectable_ids(items: Array) -> Array[String]:
	var ids: Array[String] = []
	for entry in items:
		if is_selectable(String(entry["id"])):
			ids.append(String(entry["id"]))
	return ids


## Selects a row. False (nothing changes) if it is not a selectable row of `items`
## or the question is up.
func select(item_id: String, items: Array) -> bool:
	if choosing or not is_selectable(item_id):
		return false
	for i in items.size():
		if String(items[i]["id"]) == item_id:
			selected = item_id
			_row = i
			return true
	return false


## Keeps the selection valid after the bag changed. A selected row that is gone
## moves the selection to the nearest selectable row, or to nothing.
func sync(items: Array) -> void:
	book.sync(items)
	if selected == "":
		return
	for i in items.size():
		if String(items[i]["id"]) == selected:
			_row = i
			return
	var best := -1
	for i in items.size():
		if is_selectable(String(items[i]["id"])) and (best < 0 or absi(i - _row) < absi(best - _row)):
			best = i
	if best < 0:
		selected = ""
		choosing = false
		return
	selected = String(items[best]["id"])
	_row = best


## "left", "right", "up", "down" or "place" if `event` is a press of ANY player's
## movement or place key (movement repeats while held), else "".
static func action_for(event: InputEvent) -> String:
	for player in [1, 2]:
		for direction in ["left", "right", "up", "down"]:
			if event.is_action_pressed("p%d_%s" % [player, direction], true):
				return direction
		if event.is_action_pressed("p%d_pick" % player):
			return "place"
	return ""


## A key action. In the list: the first press shows the cursor on the first
## selectable row ("selected"), then left/up and right/down step between the
## selectable rows with wrap ("moved"), and place opens the question ("ask").
## In the question: left/up and right/down switch buttons ("moved") and place
## says "drink". On the notebook row place says "notebook" (open it). "" if nothing
## happened (no selectable rows, or the notebook is showing).
func key(action: String, items: Array) -> String:
	if action == "":
		return ""
	if notebook_open:
		return ""  # the notebook's own keys (flip, scroll) are the HUD's business
	if choosing:
		if action == "place":
			return "drink"
		choice = posmod(choice + (1 if action in ["right", "down"] else -1), CHOICES.size())
		return "moved"
	var ids := selectable_ids(items)
	if ids.is_empty():
		return ""
	if selected == "" or not ids.has(selected):
		select(ids[0], items)
		return "selected"
	if action == "place":
		return "notebook" if is_notebook(selected) else "ask"
	var at := ids.find(selected)
	select(ids[posmod(at + (1 if action in ["right", "down"] else -1), ids.size())], items)
	return "moved"


## The traveler to preselect: the one with fewer hearts, Nestor if equal. Takes
## half-units. Returns an index into CHOICES.
static func preselect(nestor_units: int, fernanda_units: int) -> int:
	return 1 if fernanda_units < nestor_units else 0


## Opens the question for the selected row. False if nothing selectable is selected.
func open_choice(nestor_units: int, fernanda_units: int) -> bool:
	if selected == "" or not is_elixir(selected):
		return false
	choosing = true
	choice = preselect(nestor_units, fernanda_units)
	return true


func cancel_choice() -> bool:
	if not choosing:
		return false
	choosing = false
	return true


## "3.5" or "4": hearts without a pointless ".0" (display only).
static func hearts_number(hearts: float) -> String:
	return str(int(hearts)) if is_equal_approx(hearts, floorf(hearts)) else "%.1f" % hearts


## The selected elixir is drunk by `traveler`: exactly one is removed from `inventory`
## and GameState.heal() is called with the item's heal_units. The question closes.
## Returns {ok, item, who, nominal, healed, wasted} in half-units, or {"ok": false}
## (nothing consumed) if no elixir is selected, none is held, or the traveler is dead.
func drink(inventory, traveler: String) -> Dictionary:
	choosing = false
	if selected == "" or not is_elixir(selected) or not GameState.TRAVELERS.has(traveler):
		return {"ok": false}
	if inventory.count(selected) < 1 or not GameState.is_alive(traveler):
		return {"ok": false}
	var item_id := selected
	var nominal := int(Content.item(item_id).get("heal_units", 0))
	var before := int(GameState.heart_units[traveler])
	inventory.remove(item_id)  # may drop the row and move the selection (the HUD syncs)
	GameState.heal(traveler, nominal)
	var healed := int(GameState.heart_units[traveler]) - before
	return {"ok": true, "item": item_id, "who": traveler, "nominal": nominal, "healed": healed, "wasted": nominal - healed}


## Shows `text` for `seconds`.
func set_message(text: String, seconds: float, wasted := false) -> void:
	message = text
	message_left = seconds
	message_wasted = wasted


## Counts the message down; it disappears at 0.
func tick(delta: float) -> void:
	if message == "":
		return
	message_left -= delta
	if message_left <= 0.0:
		message = ""
		message_left = 0.0
		message_wasted = false


## An amount of half-units as hearts text: "½ heart", "1 heart", "1½ hearts". `words`
## is backpack_hud.messages.
@warning_ignore("integer_division")
static func amount_text(units: int, words: Dictionary) -> String:
	var per := maxi(GameState.units_per_heart(), 1)
	var whole := units / per
	var half := units % per != 0
	var number := (str(whole) if whole > 0 else "") + (String(words["half_glyph"]) if half else "")
	return "%s %s" % [number, words["heart"] if whole == 0 or (whole == 1 and not half) else words["hearts"]]


## The result line for a drink() result, from backpack_hud.messages.
static func message_for(result: Dictionary, words: Dictionary) -> String:
	var item: Dictionary = Content.item(String(result["item"]))
	var values := {
		"who": String(result["who"]).capitalize(),
		"item": String(item.get("name_ko", "")) if String(item.get("name_ko", "")) != "" else String(item.get("name_en", result["item"])),
		"healed": amount_text(int(result["healed"]), words),
		"wasted": amount_text(int(result["wasted"]), words),
	}
	if int(result["healed"]) == 0:
		return String(words["wasted"]).format(values)
	if int(result["wasted"]) > 0:
		return String(words["partial"]).format(values)
	return String(words["drank"]).format(values)
