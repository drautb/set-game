@tool
class_name Card
extends Container

const card_scene: PackedScene = preload("res://scenes/card.tscn")
const shape_scenes = [
  preload("res://scenes/oval_shape.tscn"),
  preload("res://scenes/diamond_shape.tscn"),
  preload("res://scenes/curve_shape.tscn")
]


signal card_clicked


var tween_rot: Tween
var tween_hover: Tween


var card_number: int = -1:
  set(new_card_number):
    card_number = new_card_number
    shape_color = _get_color(card_number)
    shape_count = _get_count(card_number)
    shape = _get_shape(card_number)
    fill = _get_fill_pattern(card_number)


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

@onready var card_face: SubViewportContainer = $CardFaceSubViewportContainer
@onready var shapes_container = $CardFaceSubViewportContainer/SubViewport/CardFace/MarginContainer/Shapes


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


func _update_card_number() -> void:
  if card_number >= 0:
    return

  print("UPDATING CARD NUMBER: " + str(self))

  card_number = ((shape_count - 1) * 27) + \
    (shape_color * 9) + \
    (fill * 3) + \
    shape


func _ready() -> void:
  _update_card_number()
  _update_shapes()


func _to_string() -> String:
  var args = [
    card_number,
    shape_count,
    Constants.get_color_name(shape_color),
    Constants.get_fill_name(fill),
    Constants.get_shape_name(shape)
  ]
  return "[CARD %d: %s %s %s %s]" % args


func _on_gui_input(event: InputEvent) -> void:
  if event.is_action_released("ui_select"):
    emit_signal("card_clicked", self)

  var mouse_pos: Vector2 = get_local_mouse_position()

  var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
  var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)

  var angle_x_max = 0.2
  var angle_y_max = 0.2

  var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
  var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))

  card_face.material.set_shader_parameter("x_rot", rot_y)
  card_face.material.set_shader_parameter("y_rot", rot_x)


func _on_mouse_entered() -> void:
  if tween_hover and tween_hover.is_running():
    tween_hover.kill()
  tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
  tween_hover.tween_property(self, "scale", Vector2(1.15, 1.15), 0.5)


func _on_mouse_exited() -> void:
  # Reset rotation
  if tween_rot and tween_rot.is_running():
    tween_rot.kill()
  tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
  tween_rot.tween_property(card_face.material, "shader_parameter/x_rot", 0.0, 0.5)
  tween_rot.tween_property(card_face.material, "shader_parameter/y_rot", 0.0, 0.5)

  # Reset scale
  if tween_hover and tween_hover.is_running():
    tween_hover.kill()
  tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
  tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)


static func new_card(new_card_number: int) -> Card:
  var card = card_scene.instantiate()
  card.card_number = new_card_number;
  return card;


static func _get_count(new_card_number: int) -> int:
  @warning_ignore("integer_division")
  return int(new_card_number / 27) + 1


static func _get_color(new_card_number: int) -> Constants.COLOR:
  @warning_ignore("integer_division")
  return int((new_card_number % 27) / 9) as Constants.COLOR


static func _get_fill_pattern(new_card_number: int) -> Constants.FILL:
  @warning_ignore("integer_division")
  return int(((new_card_number % 27) % 9) / 3) as Constants.FILL


static func _get_shape(new_card_number: int) -> Constants.SHAPE:
  return int(((new_card_number % 27) % 9) % 3) as Constants.SHAPE
