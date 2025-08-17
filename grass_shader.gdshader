shader_type spatial;
uniform vec4 base_colour : source_color;
uniform vec4 tip_colour : source_color;
uniform sampler2D perlin_noise;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 lerp(vec4 a, vec4 b, float t) {
	return (1.0 - t) * a + t * b;
}

void vertex() {
	vec4 world_coords = MODEL_MATRIX * vec4(VERTEX, 1.0);
	vec2 world_uv = (world_coords.xz + 128.0) / 256.0;
	float local_noise = length(texture(perlin_noise, world_uv + TIME / 64.0));
	// Apply wind
	VERTEX.x += sin(TIME * 0.6 + world_coords.z * 0.1 + local_noise * 2.0) * VERTEX.y * 1.5;
	VERTEX.z += sin(TIME * 0.6 + world_coords.x * 0.1 + local_noise * 2.0) * VERTEX.y * 1.5;
	// Face all vertices in the opposite direction of the camera's dir
	vec3 to_camera = CAMERA_DIRECTION_WORLD;
	to_camera.y = 0.0;
	float angle_to_rotate = atan(to_camera.x, to_camera.z) - atan(-1, 0);
	mat4 rotation_matrix = mat4(vec4(cos(angle_to_rotate), 0, -sin(angle_to_rotate), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(sin(angle_to_rotate), 0.0, cos(angle_to_rotate), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * rotation_matrix;
	COLOR = lerp(base_colour, tip_colour, VERTEX.y * 3.433670316);
}

void fragment() {
	ALBEDO = COLOR.xyz;
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
//}
