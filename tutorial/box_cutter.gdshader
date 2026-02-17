shader_type canvas_item;

uniform vec4 dim_color : source_color = vec4(0.0, 0.0, 0.0, 0.75); // overlay tint+alpha
uniform vec2 hole_center = vec2(200.0, 200.0);  // in SCREEN pixels
uniform vec2 hole_size = vec2(300.0, 120.0);    // in SCREEN pixels
uniform float corner_radius = 18.0;             // px
uniform float softness = 12.0;                  // px (edge feather)
uniform float ring_width = 3.0;                 // px (0 disables ring)
uniform vec4 ring_color : source_color = vec4(1.0, 1.0, 1.0, 0.9);

float sd_round_rect(vec2 p, vec2 half_size, float r) {
	// Signed distance to rounded rect centered at origin
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 uv_px = SCREEN_UV * vec2(SCREEN_PIXEL_SIZE.x > 0.0 ? 1.0 / SCREEN_PIXEL_SIZE.x : 0.0,
	                              SCREEN_PIXEL_SIZE.y > 0.0 ? 1.0 / SCREEN_PIXEL_SIZE.y : 0.0);
	// The above line is a bit defensive; simplest is:
	// vec2 uv_px = SCREEN_UV / SCREEN_PIXEL_SIZE;
	// But keep reading—I'll use the simple one below.

	uv_px = SCREEN_UV / SCREEN_PIXEL_SIZE; // SCREEN pixel coordinates

	vec2 half_size = hole_size * 0.5;

	// Distance from current pixel to the rounded rectangle boundary
	float d = sd_round_rect(uv_px - hole_center, half_size, corner_radius);

	// hole_alpha = 0 inside hole, 1 outside hole, with soft edge
	float hole_alpha = smoothstep(0.0, softness, d);

	// Base dim overlay
	vec4 col = dim_color;
	col.a *= hole_alpha; // punch the hole (soft)

	// Optional ring (drawn on the edge of the hole)
	if (ring_width > 0.0) {
		// A band around the boundary: near d == 0
		float ring = 1.0 - smoothstep(ring_width, ring_width + softness, abs(d));
		// Keep ring mostly outside the hole (so it doesn't tint the inside)
		ring *= hole_alpha;
		col.rgb = mix(col.rgb, ring_color.rgb, ring * ring_color.a);
	}

	COLOR = col;
}
