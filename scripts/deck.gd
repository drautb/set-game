extends Node

var card_scene = preload("res://scenes/card.tscn")

# 3 Shapes
# 3 Counts
# 3 Patterns
# 3 Colors
# = 3^4 = 81 possible cards
const CARD_COUNT = 81

var deck = []


func _ready() -> void:
  for i in range(CARD_COUNT):
    deck.push_back(i)
  shuffle()


func shuffle() -> void:
  deck.shuffle()


func is_empty() -> bool:
  return deck.is_empty()


func take_next() -> Card:
  assert(not deck.is_empty())
  return Card.new_card(deck.pop_back())


func put_on_bottom(card_number) -> void:
  deck.push_front(card_number)
