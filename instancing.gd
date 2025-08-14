extends MultiMeshInstance3D

func _init() -> void:
	var rd := RenderingServer.create_local_rendering_device()
	var shader_file := load("res://grass_compute.glsl")
	print("Compiling shader...")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	var buffer_bytes := multimesh.buffer.to_byte_array()
	var buffer := rd.storage_buffer_create(buffer_bytes.size(), buffer_bytes)
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	var uniform_set := rd.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 5, 1, 1)
	rd.compute_list_end()
	print("Submitting shader...")
	rd.submit()
	rd.sync()
	print("Compute shader executed")
	multimesh.buffer = rd.buffer_get_data(buffer).to_float32_array()
	rd.free_rid(buffer)
	rd.free_rid(pipeline)
	rd.free_rid(uniform_set)
