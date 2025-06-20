shader_type canvas_item;

const float EPSILON = 0.008;

uniform vec4 color: source_color;
uniform float radius = 0.25;
uniform float margin = 0.05;
uniform int fill_pattern: hint_range(0, 2);


bool point_inside_shape(vec2 point, vec2 top_center, vec2 bottom_center) {
  float left_edge = 0.5 - radius;
  float right_edge = 0.5 + radius;
  float top_edge = pow(point.x - top_center.x, 2.0) + pow(point.y - top_center.y, 2.0) - pow(radius, 2.0);
  float bottom_edge = pow(point.x - bottom_center.x, 2.0) + pow(point.y - bottom_center.y, 2.0) - pow(radius, 2.0);
  return point.x > left_edge
    && point.x < right_edge
    && point.y > top_center.y
    && point.y < bottom_center.y
    || (top_edge < 0.0 || bottom_edge < 0.0);
}

void fragment() {
  vec2 top_center = vec2(0.5, margin + radius);
  vec2 bottom_center = vec2(0.5, 1.0 - margin - radius);

  // (x - h)² + (y - k)² = r²
  float top_circle = length(pow(UV.x - top_center.x, 2.0) + pow(UV.y - top_center.y, 2.0) - pow(radius, 2.0));
  float bottom_circle = length(pow(UV.x - bottom_center.x, 2.0) + pow(UV.y - bottom_center.y, 2.0) - pow(radius, 2.0));
  if ((top_circle < EPSILON && UV.y < top_center.y) ||
      (bottom_circle < EPSILON && UV.y > bottom_center.y) ||
      (length(UV.x - 0.5 - radius) < 2.0 * EPSILON && UV.y > top_center.y && UV.y < bottom_center.y) ||
      (length(UV.x - 0.5 + radius) < 2.0 * EPSILON && UV.y > top_center.y && UV.y < bottom_center.y)) {
    COLOR = color;
  } else {
    COLOR = vec4(0);
  }

  // Stripe
  if (fill_pattern == 1) {
    if (int(UV.y * 128.0) % 5 == 0 && point_inside_shape(UV, top_center, bottom_center)) {
      COLOR = color;
    }
  }

  // Fill
  if (fill_pattern == 2) {
    if (point_inside_shape(UV, top_center, bottom_center)) {
      COLOR = color;
    }
  }
}
