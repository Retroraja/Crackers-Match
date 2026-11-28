// CSS box painter: rounded corners, background colour + up to 2 gradient layers, border,
// outer and inset box-shadows. The ColorRect is grown by `margin` on every side so outer shadows fit.
shader_type canvas_item;

uniform vec2 size = vec2(100.0, 100.0);
uniform float margin = 0.0;
uniform vec4 radius = vec4(0.0); // tl, tr, br, bl
uniform vec4 bgc = vec4(0.0);
// gradient layers: type 0 none, 1 linear, 2 radial
uniform int g0_type = 0;
uniform float g0_ang = 180.0;
uniform vec2 g0_cen = vec2(0.5);
uniform vec2 g0_rad = vec2(0.5);
uniform int g0_n = 0;
uniform vec4 g0_c[6];
uniform float g0_p[6];
uniform int g1_type = 0;
uniform float g1_ang = 180.0;
uniform vec2 g1_cen = vec2(0.5);
uniform vec2 g1_rad = vec2(0.5);
uniform int g1_n = 0;
uniform vec4 g1_c[6];
uniform float g1_p[6];
uniform vec4 bw = vec4(0.0); // top right bottom left
uniform vec4 bcol = vec4(0.0);
// shadows: x, y, blur, spread ; colour ; inset flag
uniform int sh_n = 0;
uniform vec4 sh_g[4];
uniform vec4 sh_c[4];
uniform float sh_in[4];

float sd_rbox(vec2 p, vec2 b, vec4 r) {
	// p relative to centre; r = tl,tr,br,bl
	float rr = (p.x > 0.0) ? ((p.y > 0.0) ? r.z : r.y) : ((p.y > 0.0) ? r.w : r.x);
	vec2 q = abs(p) - b + rr;
	return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - rr;
}

vec4 ramp(int n, vec4 c[6], float p[6], float t) {
	if (n <= 0) return vec4(0.0);
	if (t <= p[0]) return c[0];
	for (int i = 1; i < 6; i++) {
		if (i >= n) break;
		if (t <= p[i]) {
			float k = (t - p[i - 1]) / max(p[i] - p[i - 1], 1e-5);
			return mix(c[i - 1], c[i], k);
		}
	}
	return c[n - 1];
}

float gt(int type, float ang, vec2 cen, vec2 rad, vec2 lp) {
	// lp = local position 0..size
	if (type == 1) {
		float a = radians(ang);
		vec2 dir = vec2(sin(a), -cos(a));
		float L = abs(size.x * sin(a)) + abs(size.y * cos(a));
		return dot(lp - size * 0.5, dir) / L + 0.5;
	}
	if (type == 3) {
		// repeating conic: rad.x = period in degrees
		vec2 d2 = lp - cen * size;
		float a = degrees(atan(d2.x, -d2.y));
		if (a < 0.0) a += 360.0;
		return fract(a / max(rad.x, 0.01));
	}
	vec2 d = (lp - cen * size) / max(rad * size, vec2(1e-3));
	return length(d);
}

vec4 over(vec4 top, vec4 bot) {
	float a = top.a + bot.a * (1.0 - top.a);
	if (a < 1e-5) return vec4(0.0);
	return vec4((top.rgb * top.a + bot.rgb * bot.a * (1.0 - top.a)) / a, a);
}

void fragment() {
	vec4 RR = min(radius, vec4(0.5 * min(size.x, size.y)));
	vec2 full = size + vec2(margin * 2.0);
	vec2 lp = UV * full - vec2(margin);
	vec2 p = lp - size * 0.5;
	float d = sd_rbox(p, size * 0.5, RR);
	float aa = 0.7;
	float inside = clamp(0.5 - d / aa, 0.0, 1.0);
	vec4 res = vec4(0.0);
	// outer shadows (under the box)
	for (int i = 3; i >= 0; i--) {
		if (i >= sh_n || sh_in[i] > 0.5) continue;
		vec4 g = sh_g[i];
		vec2 ps = p - g.xy;
		float ds = sd_rbox(ps, size * 0.5 + vec2(g.w), RR + vec4(g.w));
		float s = (g.z > 0.0) ? 1.0 - smoothstep(-g.z * 0.5, g.z * 0.5, ds) : clamp(0.5 - ds / aa, 0.0, 1.0);
		vec4 sc = sh_c[i];
		sc.a *= s * (1.0 - inside);
		res = over(sc, res);
	}
	// fill
	vec4 f = bgc;
	if (g1_type > 0) f = over(ramp(g1_n, g1_c, g1_p, gt(g1_type, g1_ang, g1_cen, g1_rad, lp)), f);
	if (g0_type > 0) f = over(ramp(g0_n, g0_c, g0_p, gt(g0_type, g0_ang, g0_cen, g0_rad, lp)), f);
	// inset shadows
	for (int i = 0; i < 4; i++) {
		if (i >= sh_n || sh_in[i] < 0.5) continue;
		vec4 g = sh_g[i];
		vec2 ps = p - g.xy;
		float ds = sd_rbox(ps, size * 0.5 - vec2(g.w), RR - vec4(g.w));
		float s = (g.z > 0.0) ? smoothstep(-g.z * 0.5, g.z * 0.5, ds) : clamp(0.5 + ds / aa, 0.0, 1.0);
		vec4 sc = sh_c[i];
		sc.a *= s;
		f = over(sc, f);
	}
	// border
	float b = max(max(bw.x, bw.y), max(bw.z, bw.w));
	if (b > 0.0 && bcol.a > 0.0) {
		float din = sd_rbox(p, size * 0.5 - vec2(b), max(RR - vec4(b), vec4(0.0)));
		float ring = clamp(0.5 + din / aa, 0.0, 1.0);
		f = over(vec4(bcol.rgb, bcol.a * ring), f);
	}
	f.a *= inside;
	res = over(f, res);
	COLOR = res;
}
