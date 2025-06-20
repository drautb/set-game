@tool
extends Control

signal card_selected
signal card_deselected

var selected = false

@onready var animations = $AnimationPlayer

var shape_scenes = [
  preload("res://scenes/oval_shape.tscn"),
  preload("res://scenes/diamond_shape.tscn"),
  preload("res://scenes/curve_shape.tscn")
]

@export var shape: Constants.SHAPE = Constants.SHAPE.OVAL:
  set(new_shape):
    shape = new_shape
    _update_shapes()

@export var shape_color: Constants.COLOR = Constants.COLOR.RED:
  set(new_color):
    shape_color = new_color
    _update_shapes()

@export_range(1, 3, 1) var shape_count: int = 1:
  set(new_count):
    shape_count = new_count
    _update_shapes()

@export var fill: Constants.FILL = Constants.FILL.EMPTY:
  set(new_fill):
    fill = new_fill
    _update_shapes()

@onready var shapes_container = $CardFace/MarginContainer/Shapes


func _update_shapes() -> void:
  if !is_instance_valid(shapes_container):
    return

  for c in shapes_container.get_children():
    c.queue_free()

  var shape_scene = shape_scenes[int(shape)]
  for i in range(shape_count):
    var shape_node = shape_scene.instantiate()
    shape_node.color = Constants.COLOR_MAP[shape_color]
    shape_node.fill_pattern = fill
    shapes_container.add_child(shape_node);


func _ready() -> void:
  _update_shapes()


func _on_gui_input(event: InputEvent) -> void:
  if event.is_action_released("ui_select"):
    selected = !selected
    if selected:
      animations.play("lift")
      emit_signal("card_selected", self)
    else:
      animations.play_backwards("lift")
      emit_signal("card_deselected", self)


func deselect() -> void:
  if selected:
    selected = false
    animations.play_backwards("lift")
    emit_signal("card_deselected", self)
