extends Node3D

func _ready() -> void:
	# Create a local rendering device.
	var rd := RenderingServer.create_local_rendering_device()
	var shader_file := load("res://grass_compute.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	var view = RDTextureView.new()
	var noise = NoiseTexture2D.new()
	noise.width = 256
	noise.height = 256
	noise.noise = load("res://heightmap_noise.tres")
	noise.generate_mipmaps = false
	noise.normalize = true
	noise.seamless = true
	noise.seamless_blend_skirt = 0.1
	await noise.changed
	var image = noise.get_image()
	image.convert(Image.FORMAT_RGBAF)
	for i in range(32):
		for j in range(32):
			var grass_instance = MultiMeshInstance3D.new()
			add_child(grass_instance)
			grass_instance.multimesh = MultiMesh.new()
			grass_instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
			grass_instance.multimesh.instance_count = 64 * 64
			grass_instance.multimesh.mesh = load("res://Grass.obj")
			grass_instance.material_override = ShaderMaterial.new()
			grass_instance.material_override.shader = load("res://grass_shader.gdshader")
			grass_instance.material_override.set("shader_parameter/base_colour", Color("#4a3823"))
			grass_instance.material_override.set("shader_parameter/tip_colour", Color("#e1ac6a"))
			grass_instance.material_override.set("shader_parameter/perlin_noise", load("res://grass_noise.tres"))
			var input_bytes = grass_instance.multimesh.buffer.to_byte_array()
			var buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
			var uniform := RDUniform.new()
			uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
			uniform.binding = 0
			uniform.add_id(buffer)
			var tex_uniform := RDUniform.new()
			tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
			tex_uniform.binding = 1
			var corner_uniform := RDUniform.new()
			corner_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
			corner_uniform.binding = 2
			var corner := PackedFloat32Array([-128.0 + i * 8, -128.0 + j * 8, 0.0, 0.0])
			var corner_buffer := rd.uniform_buffer_create(corner.to_byte_array().size(), corner.to_byte_array())
			corner_uniform.add_id(corner_buffer)
			var sampler_state := RDSamplerState.new()
			var sampler := rd.sampler_create(sampler_state)
			var fmt := RDTextureFormat.new()
			fmt.width = image.get_width()
			fmt.height = image.get_height()
			fmt.mipmaps = 1
			fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
			fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
			var tex = rd.texture_create(fmt, view, [image.get_data()])
			tex_uniform.add_id(sampler)
			tex_uniform.add_id(tex)
			var uniform_set := rd.uniform_set_create([uniform, tex_uniform, corner_uniform], shader, 0)
			var pipeline := rd.compute_pipeline_create(shader)
			var compute_list := rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
			rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
			rd.compute_list_dispatch(compute_list, 8, 8, 1)
			rd.compute_list_end()
			rd.submit()
			rd.sync()
			grass_instance.multimesh.buffer = rd.buffer_get_data(buffer).to_float32_array()
			rd.free_rid(uniform_set)
			rd.free_rid(buffer)
			rd.free_rid(corner_buffer)
			rd.free_rid(tex)
			rd.free_rid(sampler)
			rd.free_rid(pipeline)
	rd.free_rid(shader)
