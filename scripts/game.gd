extends CenterContainer

var _selected_cards = []


@onready var card_grid = $HBoxContainer/MarginContainer/CardGrid


func _ready() -> void:
  for i in range(12):
    var card = Deck.take_next()
    card.card_selected.connect(_on_card_selected)
    card.card_deselected.connect(_on_card_deselected)
    card_grid.add_child(card)


func _unhandled_key_input(event: InputEvent) -> void:
  if event.is_action_released("ui_accept"):
    if _is_a_set(_selected_cards):
      for c in _selected_cards:
        c.queue_free()


func _on_card_selected(card: Node) -> void:
  if _selected_cards.size() < 3:
    _selected_cards.push_back(card)
  else:
    card.deselect()


func _on_card_deselected(card: Node) -> void:
  _selected_cards.erase(card)


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
