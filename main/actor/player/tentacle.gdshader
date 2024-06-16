shader_type canvas_item;

uniform float a;
uniform float f;
uniform float s;

void fragment() {
	vec2 uv = UV;
	uv.y -= a * sin(s - uv.x * f);
	COLOR = texture(TEXTURE, uv);
}
