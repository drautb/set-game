extends Node

var card_scene = preload("res://scenes/card.tscn")

# 3 Shapes
# 3 Counts
# 3 Patterns
# 3 Colors
# = 3^4 = 81 possible cards

var deck = []
var _position = 0

func _ready() -> void:
  for i in range(81):
    deck.push_back(i)
  shuffle()


func shuffle() -> void:
  deck.shuffle()
  _position = 0


func take_next() -> Node:
  assert(_position < deck.size(), "Deck position out of bounds!")
  var card_number = deck[_position]
  _position += 1

  var card = card_scene.instantiate()
  card.shape_color = _get_color(card_number)
  card.shape_count = _get_count(card_number)
  card.shape = _get_shape(card_number)
  card.fill = _get_fill_pattern(card_number)
  return card;

func _get_color(card_number: int) -> int:
  @warning_ignore("integer_division")
  return int(card_number / 27)

func _get_count(card_number: int) -> int:
  @warning_ignore("integer_division")
  return int((card_number % 27) / 9) + 1

func _get_shape(card_number: int) -> int:
  @warning_ignore("integer_division")
  return int(((card_number % 27) % 9) / 3)

func _get_fill_pattern(card_number: int) -> int:
  return int(((card_number % 27) % 9) % 3)
