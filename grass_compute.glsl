#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
    float data[];
}
my_data_buffer;

// Heightmap used to make the grass positions adhere to the terrain surface
layout(set = 0, binding = 1) uniform sampler2D heightMap;

int grassLength = 64;

layout (set = 0, binding = 2) restrict uniform VecBuffer {
  vec2 cornerPoint;
} cornerBuffer;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}


// The code we want to execute in each invocation
void main() {
    vec2 grass_position = (gl_GlobalInvocationID.xy) / 8.0 + cornerBuffer.cornerPoint;
    grass_position.x += rand(gl_GlobalInvocationID.xy) * 4.0 - 2.0;
    grass_position.y += rand(gl_GlobalInvocationID.yx) * 4.0 - 2.0;
    float height = length(texture(heightMap, (grass_position / (256.0 / grassLength) + (grassLength / 2.0)) / grassLength)) * 15.0 - 15.0;
    uint base_index = (gl_GlobalInvocationID.y + gl_GlobalInvocationID.x * grassLength) * 12;
    grass_position += rand(gl_GlobalInvocationID.xy);
    // Set positions in buffer
    my_data_buffer.data[base_index] = 1;
    my_data_buffer.data[base_index + 1] = 0;
    my_data_buffer.data[base_index + 2] = 0;
    my_data_buffer.data[base_index + 3] = grass_position.x;
    my_data_buffer.data[base_index + 4] = 0;
    my_data_buffer.data[base_index + 5] = 1.0 + rand(gl_GlobalInvocationID.yx) * 5.0;
    my_data_buffer.data[base_index + 6] = 0;
    my_data_buffer.data[base_index + 7] = height;
    my_data_buffer.data[base_index + 8] = 0;
    my_data_buffer.data[base_index + 9] = 0;
    my_data_buffer.data[base_index + 10] = 1;
    my_data_buffer.data[base_index + 11] = grass_position.y;
}
