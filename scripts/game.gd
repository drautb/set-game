extends CenterContainer

var _selected_cards = []


@onready var card_grid = $HBoxContainer/MarginContainer/CardGrid
@onready var set_count_label = $HBoxContainer/VBoxContainerHUD/HBoxContainer/RemainingSetsValue


func _ready() -> void:
  for i in range(12):
    _deal_card()
  _update_remaining_sets()


func _deal_card() -> void:
  var card = Deck.take_next()
  card.card_selected.connect(_on_card_selected)
  card.card_deselected.connect(_on_card_deselected)
  card_grid.add_child(card)


func _update_remaining_sets() -> void:
  var set_count = _count_visible_sets()
  set_count_label.text = str(set_count)


func _unhandled_key_input(event: InputEvent) -> void:
  if event.is_action_released("ui_accept"):
    if _is_a_set(_selected_cards):
      for c in _selected_cards:
        card_grid.remove_child(c)
        c.queue_free()
      _selected_cards.clear()
      _deal_card()
      _deal_card()
      _deal_card()
      _update_remaining_sets()


func _on_card_selected(card: Node) -> void:
  if _selected_cards.size() < 3:
    _selected_cards.push_back(card)
  else:
    card.deselect()


func _on_card_deselected(card: Node) -> void:
  _selected_cards.erase(card)


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
