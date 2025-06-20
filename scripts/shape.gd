@tool
extends MarginContainer

@export var color: Color:
  set(new_color):
    color = new_color
    _update_shader()

@export var fill_pattern: Constants.FILL:
  set(new_fill_pattern):
    fill_pattern = new_fill_pattern
    _update_shader()

@onready var shape = $Shape

func _ready() -> void:
  _update_shader()


func _update_shader() -> void:
  if is_instance_valid(shape):
    shape.get_material().set("shader_parameter/color", color);
    shape.get_material().set("shader_parameter/fill_pattern", int(fill_pattern));
