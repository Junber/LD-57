shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float intensity = 1.0;

void fragment() {
    COLOR = vec4(
		textureLod(screen_texture, SCREEN_UV +
		vec2(
			sin(SCREEN_UV.y * 11.0 + TIME) * 0.02 +
			sin(SCREEN_UV.y * 20.0 - 1.5 * TIME) * 0.01
			,
			sin(SCREEN_UV.x * 7.0 + 1.3 * TIME) * 0.02 +
			sin(SCREEN_UV.x * 14.0 - 1.8 * TIME) * 0.01) * intensity, 0.0).r,

		textureLod(screen_texture, SCREEN_UV +
		vec2(
			sin(SCREEN_UV.y * 10.0 + TIME) * 0.02 +
			sin(SCREEN_UV.y * 19.0 - 1.5 * TIME) * 0.01
			,
			sin(SCREEN_UV.x * 8.0 + 1.3 * TIME) * 0.02 +
			sin(SCREEN_UV.x * 14.0 - 1.8 * TIME) * 0.01) * intensity, 0.0).g,

		textureLod(screen_texture, SCREEN_UV +
		vec2(
			sin(SCREEN_UV.y * 10.0 + TIME) * 0.02 +
			sin(SCREEN_UV.y * 22.0 - 1.5 * TIME) * 0.01
			,
			sin(SCREEN_UV.x * 6.0 + 1.3 * TIME) * 0.02 +
			sin(SCREEN_UV.x * 14.0 - 1.8 * TIME) * 0.01) * intensity, 0.0).b,

		1.0);
}
