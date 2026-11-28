// CSS filter on a picture: grayscale, brightness, drop-shadow (hard, offset only)
shader_type canvas_item;
uniform float gray = 0.0;
uniform float sepia = 0.0;
uniform float sat = 1.0;
uniform float hue = 0.0;
uniform float bright = 1.0;
uniform vec4 ds_col = vec4(0.0);
uniform vec2 ds_off = vec2(0.0);
varying vec4 vc;
void vertex() {
	vc = COLOR;
}
void fragment() {
	vec4 t = texture(TEXTURE, UV);
	if (sepia > 0.0) {
		vec3 sp = vec3(dot(t.rgb, vec3(0.393, 0.769, 0.189)), dot(t.rgb, vec3(0.349, 0.686, 0.168)), dot(t.rgb, vec3(0.272, 0.534, 0.131)));
		t.rgb = mix(t.rgb, min(sp, vec3(1.0)), sepia);
	}
	if (sat != 1.0) {
		float g0 = dot(t.rgb, vec3(0.2126, 0.7152, 0.0722));
		t.rgb = clamp(mix(vec3(g0), t.rgb, sat), 0.0, 1.0);
	}
	if (hue != 0.0) {
		float h = radians(hue);
		float c = cos(h), s = sin(h);
		mat3 m = mat3(
			vec3(0.213 + c * 0.787 - s * 0.213, 0.213 - c * 0.213 + s * 0.143, 0.213 - c * 0.213 - s * 0.787),
			vec3(0.715 - c * 0.715 - s * 0.715, 0.715 + c * 0.285 + s * 0.140, 0.715 - c * 0.715 + s * 0.715),
			vec3(0.072 - c * 0.072 + s * 0.928, 0.072 - c * 0.072 - s * 0.283, 0.072 + c * 0.928 + s * 0.072));
		t.rgb = clamp(m * t.rgb, 0.0, 1.0);
	}
	float l = dot(t.rgb, vec3(0.2126, 0.7152, 0.0722));
	t.rgb = mix(t.rgb, vec3(l), gray) * bright;
	if (ds_col.a > 0.0) {
		vec2 px = TEXTURE_PIXEL_SIZE * ds_off * 2.0;
		float sa = texture(TEXTURE, UV - px).a * ds_col.a;
		float a = t.a + sa * (1.0 - t.a);
		t = vec4(a > 0.0 ? (t.rgb * t.a + ds_col.rgb * sa * (1.0 - t.a)) / a : t.rgb, a);
	}
	COLOR = t * vc;
}
