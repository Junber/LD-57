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
	COLOR.xyz = vec3(random(TIME, random(VERTEX.x, VERTEX.y)));
}
