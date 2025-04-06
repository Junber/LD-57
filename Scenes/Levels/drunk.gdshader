shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float intensity = 1.0;

void fragment() {
    COLOR = textureLod(screen_texture, SCREEN_UV + 
		vec2(
			sin(SCREEN_UV.y * 10.0 + TIME) * 0.02 +
			sin(SCREEN_UV.y * 20.0 - 1.5 * TIME) * 0.01
			, 
			sin(SCREEN_UV.x * 7.0 + 1.3 * TIME) * 0.02 +
			sin(SCREEN_UV.x * 14.0 - 1.8 * TIME) * 0.01) * intensity, 0.0);
}
