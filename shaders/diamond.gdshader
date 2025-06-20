shader_type canvas_item;

const float EPSILON = 0.03;

uniform vec4 color: source_color;
uniform float slope = 1.75;
uniform float margin = 0.05;
uniform int fill_pattern: hint_range(0, 2);


bool point_inside_shape(float x, float y) {
  float upper_right = (-slope * x + (0.5 - margin)) - y;
  float upper_left = (slope * x + (0.5 - margin)) - y;
  float lower_left = (-slope * x - (0.5 - margin)) - y;
  float lower_right = (slope * x - (0.5 - margin)) - y;
  return (upper_right > -EPSILON && x > 0.0 && y > 0.0)
    || (upper_left > -EPSILON && x < 0.0 && y > 0.0)
    || (lower_left < -EPSILON && x < 0.0 && y < 0.0)
    || (lower_right < -EPSILON && x > 0.0 && y < 0.0);
}

void fragment() {
  COLOR = vec4(0);
  
  // Transform coordinates to have origin at center to be easier to work with
  float x = UV.x - 0.5;
  float y = -(UV.y - 0.5);
  
  // y = mx + b
  float upper_right = (-slope * x + (0.5 - margin)) - y;
  if (upper_right > -EPSILON && upper_right < EPSILON && y > 0.0 && x > 0.0) {
    COLOR = color;
  }
  
  float upper_left = (slope * x + (0.5 - margin)) - y;
  if (upper_left > -EPSILON && upper_left < EPSILON && y > 0.0 && x < 0.0) {
    COLOR = color;
  }
  
  float lower_left = (-slope * x - (0.5 - margin)) - y;
  if (lower_left > -EPSILON && lower_left < EPSILON && y < 0.0 && x < 0.0) {
    COLOR = color;
  }
  
  float lower_right = (slope * x - (0.5 - margin)) - y;
  if (lower_right > -EPSILON && lower_right < EPSILON && y < 0.0 && x > 0.0) {
    COLOR = color;
  }

  // Stripe
  if (fill_pattern == 1) {
    if (int(y * 128.0) % 5 == 0 && point_inside_shape(x, y)) {
      COLOR = color;
    }
  }

  // Fill
  if (fill_pattern == 2) {
    if (point_inside_shape(x, y)) {
      COLOR = color;
    }
  }
}
