shader_type canvas_item;

uniform float size = 50.0;

void fragment() {
	COLOR = vec4(vec3(0.0), smoothstep(0.6, 1.0, length(FRAGCOORD.xy - 0.5 / SCREEN_PIXEL_SIZE) / size));
}
