// a CSS box that was painted once into a picture (WebLayout.bake): just show the picture
shader_type canvas_item;
uniform sampler2D baked : filter_linear;
void fragment() {
	vec4 c = texture(baked, UV);
	COLOR = vec4(c.rgb / max(c.a, 0.0001), c.a) * COLOR.a;
}
