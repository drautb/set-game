shader_type canvas_item;

const float EPSILON = 0.03;

uniform vec4 color: source_color;
uniform float margin = 0.05;
uniform int fill_pattern: hint_range(0, 2);

void fragment() {
  COLOR = vec4(0.0);
  vec4 tex_color = texture(TEXTURE, UV);
	if (tex_color.g > 0.0 && tex_color.r == 0.0) {
    COLOR = color;
  }

  if (fill_pattern == 1) {
    if (int(UV.y * 128.0) % 5 == 0 && tex_color.g > 0.0) {
      COLOR = color;
    }
  } else if (fill_pattern == 2) {
    if (tex_color.r > 0.0) {
      COLOR = color;
    }
  }


}
