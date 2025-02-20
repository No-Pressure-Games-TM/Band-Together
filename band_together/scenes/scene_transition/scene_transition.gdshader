shader_type canvas_item;

// Ranges from 0 to 1 over the course of the transition.
// We use this to actually animate the shader.
uniform float progress : hint_range(0, 1);

// Size of each diamond, in pixels.
uniform float diamondPixelSize = 10.0;

void fragment() {
	vec2 dist = abs(fract(FRAGCOORD.xy/diamondPixelSize)-0.5);
    COLOR.a = step(dist.x+dist.y+UV.x+UV.y-progress*4.0,0.0);
}