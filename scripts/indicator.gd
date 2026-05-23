@tool
class_name Indicator
extends AspectRatioContainer


const OFF_COLOR = Color.DIM_GRAY
const ON_COLOR = Color.DODGER_BLUE


@onready var texture = $TextureRect


@export var on: bool = false:
  set(new_on):
    on = new_on
    _update_indicator()


func _ready() -> void:
  on = false
  _update_indicator()


func _update_indicator() -> void:
  if texture:
    texture.self_modulate = ON_COLOR if on else OFF_COLOR
