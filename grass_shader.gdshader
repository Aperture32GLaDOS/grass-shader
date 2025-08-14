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
	vec4 world_coords = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 world_uv = (world_coords.xz + 128.0) / 256.0;
	float local_noise = length(texture(perlin_noise, world_uv));
	// Face all vertices in the opposite direction of the camera's dir
	vec3 to_camera = CAMERA_DIRECTION_WORLD;
	to_camera.y = 0.0;
	float angle_to_rotate = acos(dot(to_camera, vec3(-1.0, 0.0, 0.0)) / length(to_camera));
	mat3 rotation_matrix = mat3(vec3(cos(angle_to_rotate), 0, -sin(angle_to_rotate)), vec3(0.0, 1.0, 0.0), vec3(sin(angle_to_rotate), 0.0, cos(angle_to_rotate)));
	VERTEX = rotation_matrix * VERTEX;
	// Apply wind
	VERTEX.x += sin(TIME + world_coords.z + local_noise) * VERTEX.y * local_noise * 1.5;
	VERTEX.z += sin(TIME + world_coords.x + local_noise) * VERTEX.y * local_noise * 1.5;
	COLOR = lerp(base_colour, tip_colour, VERTEX.y * 2.0);
}

void fragment() {
	ALBEDO = COLOR.xyz;
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
//}
