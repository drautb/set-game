@tool
extends Node

enum SHAPE { OVAL, DIAMOND, CURVE }
enum FILL { EMPTY, STRIPED, FULL }
enum COLOR { RED, GREEN, PURPLE }

const COLOR_MAP = {
  COLOR.RED: Color.CRIMSON,
  COLOR.GREEN: Color.WEB_GREEN,
  COLOR.PURPLE: Color.PURPLE
}

func get_shape_name(shape: SHAPE) -> String:
  match shape:
    SHAPE.OVAL:
      return "Oval"
    SHAPE.DIAMOND:
      return "Diamond"
    SHAPE.CURVE:
      return "S-Curve"
    _:
      return "Unknown"


func get_color_name(color: COLOR) -> String:
  match color:
    COLOR.RED:
      return "Red"
    COLOR.GREEN:
      return "Green"
    COLOR.PURPLE:
      return "Purple"
    _:
      return "Unknown"


func get_fill_name(fill: FILL) -> String:
  match fill:
    FILL.EMPTY:
      return "Empty"
    FILL.STRIPED:
      return "Striped"
    FILL.FULL:
      return "Full"
    _:
      return "Unknown"
