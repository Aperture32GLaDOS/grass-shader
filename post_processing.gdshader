shader_type spatial;

render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D normal_texture : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform float fog_range : hint_range(1.0, 512.0, 0.1);
uniform float sharpness_level : hint_range(0.0, 1.0, 0.1);

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

vec4 lerp(vec4 a, vec4 b, float t) {
	return (1.0 - t) * a + t * b;
}

void fragment() {
	vec2 resolution = VIEWPORT_SIZE;
	vec2 pixel_coords = SCREEN_UV * resolution;
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z / fog_range;
	// Apply sharpen filter
	vec4 new_colour = texture(screen_texture, SCREEN_UV) * 5.0;
	new_colour -= texture(screen_texture, (pixel_coords - vec2(1.0, 0.0)) / resolution);
	new_colour -= texture(screen_texture, (pixel_coords - vec2(-1.0, 0.0)) / resolution);
	new_colour -= texture(screen_texture, (pixel_coords - vec2(0.0, 1.0)) / resolution);
	new_colour -= texture(screen_texture, (pixel_coords - vec2(0.0, -1.0)) / resolution);
	// Apply fog, and lerp between sharpening and not depending on depth
	ALBEDO = lerp(texture(screen_texture, SCREEN_UV), new_colour, 1.0 - linear_depth).rgb + vec3(linear_depth);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
