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

  return Card.new_card(card_number)
