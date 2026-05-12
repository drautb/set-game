extends VBoxContainer

var _selected_cards = []
var _card_positions = {}


@onready var card_grid = $HBoxContainer/CardGridMarginContainer/CardGrid
@onready var draw_pile = $HBoxContainer/Decks/Draw
@onready var discard_pile = $HBoxContainer/Decks/Discard
@onready var selected_card_positions = $SelectedCardPositions


func _ready() -> void:
  for i in range(12):
    var new_card = _deal_card()
    #new_card.position = Constants.grid_idx_to_position(i)
    card_grid.add_child(new_card)

  _reset_selected_cards()
  _update_remaining_sets()


func _unhandled_key_input(event: InputEvent) -> void:
  if event.is_action_released("ui_accept"):
    if _is_a_set(_selected_cards):
      _replace_set()


func _replace_set() -> void:
  for i in _selected_cards.size():
    var c = _selected_cards[i]
    _replace_card(i, c)

  _reset_selected_cards()
  _update_remaining_sets()


func _replace_card(card_idx: int, card: Card) -> void:
  var c_grid_idx = card_grid.get_children().find(card)
  var new_card = _deal_card()
  card_grid.add_child(new_card)
  card_grid.move_child(new_card, c_grid_idx)
  card_grid.remove_child(card)
  self.add_child(card)

  # Wait a frame for the grid container to position the new cards
  await get_tree().process_frame

  card.position = Constants.grid_idx_to_position(c_grid_idx)
  var clear_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
  clear_tween.tween_property(card, "position", discard_pile.global_position, 0.3)
  clear_tween.tween_callback(card.queue_free)

  var target_position = Constants.grid_idx_to_position(c_grid_idx)
  # TODO: Update this to come from a deck sprite
  new_card.global_position = draw_pile.global_position

  var deal_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
  var delay = lerpf(0.3, 0.6, card_idx / 2.0)
  deal_tween.tween_property(new_card, "position", target_position, 0.5) \
    .set_delay(delay)


func _on_card_clicked(card: Card) -> void:
  if _selected_cards.has(card):
    _deselect_card(card)
  elif _selected_cards.count(0) > 0:
    _select_card(card)


func _reset_selected_cards() -> void:
  _selected_cards = [0, 0, 0]


func _deal_card() -> Card:
  var card = Deck.take_next()
  card.connect("card_clicked", _on_card_clicked)
  return card


func _select_card(card: Card) -> void:
  _card_positions[card.name] = card.position
  var idx = _selected_cards.find(0)
  var target_pos = selected_card_positions.get_child(idx).position
  _selected_cards[idx] = card

  var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
  tween.tween_property(card, "position", target_pos, 0.5)


func _deselect_card(card: Card) -> void:
  var idx = _selected_cards.find(card)
  _selected_cards[idx] = 0

  var target_pos = _card_positions[card.name]
  _card_positions.erase(card.name)

  var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
  tween.tween_property(card, "position", target_pos, 0.5)


###########################################################
## SET LOGIC
###########################################################

func _count_visible_sets() -> int:
  var sets = {}
  for c1 in card_grid.get_children():
    for c2 in card_grid.get_children():
      for c3 in card_grid.get_children():
        if c1 == c2 or c2 == c3 or c1 == c3:
          continue

        var cards = [c1, c2, c3]
        if _is_a_set([c1, c2, c3]):
          cards.sort_custom(func(a, b): return a.card_number < b.card_number)
          sets[cards] = true

  print("REMAINING SETS")
  for s in sets:
    print("  SET: " + str(s))
  return sets.size()


func _update_remaining_sets() -> void:
  var set_count = _count_visible_sets()
  print("Remaining Sets: " + str(set_count))


func _is_a_set(cards: Array) -> bool:
  if cards.size() != 3:
    return false

  var uniq_shapes = {}
  var uniq_colors = {}
  var uniq_counts = {}
  var uniq_fills = {}
  for c in cards:
    uniq_shapes[c.shape] = true
    uniq_colors[c.shape_color] = true
    uniq_counts[c.shape_count] = true
    uniq_fills[c.fill] = true

  if uniq_shapes.size() == 2 || \
      uniq_colors.size() == 2 || \
      uniq_counts.size() == 2 || \
      uniq_fills.size() == 2:
    return false

  return true
