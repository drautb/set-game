extends ColorRect

var _selected_cards = []
var _card_positions = {}

var _sets_found = 0
var _score = 0


@onready var card_area = $CardArea
@onready var cards = $CardArea/Cards
@onready var card_positions = $CardArea/CardPositions
@onready var draw_pile = $Decks/Draw
@onready var discard_pile = $Decks/Discard
@onready var selected_card_positions = $CardArea/SelectedCardPositions

@onready var set_count_label = $HUD/SetCountValue
@onready var score_value_label = $HUD/ScoreValue


func _ready() -> void:
  _deal_new_cards()


func _unhandled_key_input(event: InputEvent) -> void:
  if event.is_action_released("ui_accept"):
    var three_cards = _selected_cards.filter(func(c): return c is Card)
    if _is_a_set(three_cards):
      _score += _get_score(three_cards)
      _sets_found += 1
      _refresh_hud()
      _replace_set()
    else:
      for c: Card in three_cards:
        _deselect_card(c)

  if event.is_action_released("set_refresh_cards"):
    _deal_new_cards()


func _refresh_hud() -> void:
  set_count_label.text = str(_sets_found)
  score_value_label.text = str(_score)


func _replace_set() -> void:
  var tween = null
  for i in _selected_cards.size():
    var c = _selected_cards[i]
    tween = _replace_card(i, c)

  if tween:
    await tween.finished
  await get_tree().process_frame

  _reset_selected_cards()
  _update_remaining_sets()


func _replace_card(card_idx: int, card: Card) -> Tween:
  var c_grid_idx = cards.get_children().find(card)

  if not Deck.is_empty():
    var new_card = _deal_card()
    cards.add_child(new_card)
    cards.move_child(new_card, c_grid_idx)
    cards.remove_child(card)
    card_area.add_child(card)

    new_card.position = draw_pile.position
    var target_position = card_positions.get_child(c_grid_idx).position

    var delay = lerpf(0.3, 0.6, card_idx / 2.0)
    _animate_deal(new_card, target_position, delay)

  return _animate_discard(card, discard_pile.global_position)


func _animate_deal(card: Card, target_position: Vector2, delay: float = 0.0) -> Tween:
  var deal_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
  deal_tween.tween_property(card, "position", target_position, 0.5) \
    .set_delay(delay)
  return deal_tween


func _animate_discard(card: Card, pile_position: Vector2, delay: float = 0.0) -> Tween:
  var clear_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
  clear_tween.tween_property(card, "position", pile_position, 0.5).set_delay(delay)
  clear_tween.tween_callback(card.queue_free)
  return clear_tween


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
  for c1: Card in cards.get_children():
    for c2: Card in cards.get_children():
      for c3: Card in cards.get_children():
        if c1 == c2 or c2 == c3 or c1 == c3:
          continue

        var current_cards = [c1, c2, c3]
        if _is_a_set([c1, c2, c3]):
          current_cards.sort_custom(func(a, b): return a.card_number < b.card_number)
          sets[current_cards] = true

  print("REMAINING SETS")
  for s in sets:
    print("  SET: " + str(s))
  return sets.size()


func _update_remaining_sets() -> void:
  var set_count = _count_visible_sets()
  print("Remaining Sets: " + str(set_count))
  if set_count == 0 and not Deck.is_empty():
    _deal_new_cards()


func _deal_new_cards() -> void:
  var delay = 0.0
  var tween = null
  var current_cards = cards.get_children()
  current_cards.reverse()
  for c: Card in current_cards:
    Deck.put_on_bottom(c.card_number)
    tween = _animate_discard(c, discard_pile.global_position, delay)
    delay += 0.05

  if tween:
    await tween.finished

  # Wait for discards to all be freed
  await get_tree().process_frame

  delay = 0.0
  for i in range(12):
    if Deck.is_empty():
      continue
    var new_card = _deal_card()
    cards.add_child(new_card)
    new_card.position = draw_pile.position
    tween = _animate_deal(new_card, card_positions.get_child(i).position, delay)
    delay += 0.05

  if tween:
    await tween.finished

  _reset_selected_cards()
  _update_remaining_sets()


func _is_a_set(three_cards: Array) -> bool:
  if three_cards.size() != 3 or three_cards.has(0):
    return false

  return not _get_uniq_attributes(three_cards).has(2)


func _get_score(three_cards: Array) -> int:
  var uniq_attributes = _get_uniq_attributes(three_cards)
  assert(not uniq_attributes.has(2))
  return uniq_attributes.count(3)


func _get_uniq_attributes(three_cards: Array) -> Array:
  var uniq_shapes = {}
  var uniq_colors = {}
  var uniq_counts = {}
  var uniq_fills = {}
  for c in three_cards:
    uniq_shapes[c.shape] = true
    uniq_colors[c.shape_color] = true
    uniq_counts[c.shape_count] = true
    uniq_fills[c.fill] = true

  return [uniq_shapes.size(), uniq_colors.size(), uniq_counts.size(), uniq_fills.size()]
