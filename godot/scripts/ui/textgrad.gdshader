// gradient fill for text (CSS background-clip:text); the outline keeps its own colour.
// The label's font colour must be pure white so fill glyphs can be told apart from the outline.
shader_type canvas_item;
uniform float h = 40.0;
uniform float y0 = 0.0;
uniform int n = 2;
uniform vec4 c[6];
uniform float p[6];
varying float vy;
void vertex() { vy = VERTEX.y; }
void fragment() {
	vec4 t = texture(TEXTURE, UV);
	if (COLOR.r > 0.99 && COLOR.g > 0.99 && COLOR.b > 0.99) {
		float k = clamp((vy - y0) / h, 0.0, 1.0);
		vec4 g = c[0];
		for (int i = 1; i < 6; i++) {
			if (i >= n) break;
			if (k <= p[i]) { g = mix(c[i - 1], c[i], (k - p[i - 1]) / max(p[i] - p[i - 1], 1e-5)); break; }
			g = c[i];
		}
		COLOR = vec4(g.rgb, g.a * t.a * COLOR.a);
	} else {
		COLOR = vec4(COLOR.rgb, COLOR.a * t.a);
	}
}
