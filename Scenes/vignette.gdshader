shader_type canvas_item;

float random(float x, float y)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(vec2(x, y) ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void fragment() {
	COLOR = vec4(random(TIME, random(UV.x, UV.y)) * 0.2 + 0.8, 0.0, 0.0, pow(
		mix(0.0, 1.0, max(length(0.5 - UV), 0.2)), 
		0.6 - 0.4 * pow(max(sin(TIME), 0.0), 2.0)
	));
}
