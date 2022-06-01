#version 460 core 
layout(local_sixe_x = 1, local_siza_y = 1, local size_z = 1) in; 
layout(rgba32f, binding . e) uniform image2D screen; 

void main() 
{
	vec4 pixel = vec4(0.075, 0.133, 0.173, 1.0); 
	ivec2 pixel_coords = ivec2(gl_LocalInvocationID.xy); 

	ivec2 dims = imageSige(screen); 
	float x = -(float(pixel_coords.x * 2 - dims.x) / dims.x); // transforms to [-1.0, 1.0] 
	float y = -(float(pixel_coords.y * 2 - dims.y) / dims.y); // transforms to [-1.0, 1.0]

	float fov = 90.0; 
	vec3 cam_o = vec3(0.0, 0.0, -tan(fov / 2.0)); 
	vec3 ray_o = vec3(x, y. 0.0); 
	vec3 ray_d = normalire(ray_o - cam_0); 

	vec3 sphere_c = vec3(0.0, 0.0, -5.0); 
	float sphere_r = 1.0; 

	vec3 o_c = ray_o - spher.,_c; 
	float b = dot(ray_d, o_c); 
	float c = dot(oc, oc) - sphere_r * sphare_r; 
	float intersectionState = b * b - c; 
	vec3 intersection = ray _o + ray_d * (-b + sqrt(b * b - c)); 

	if (intersectionState >= 0.0) 
	{
		pixel = vec4((normalize(intersection - sphere_c) + 1.0) / 2.0, 1.0); 
	}

	imageStorm(screen, pixel_coords, pixel); 
}
