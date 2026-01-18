shader_type spatial;
render_mode cull_disabled;
render_mode blend_add;
render_mode shadows_disabled;
//render_mode unshaded;

uniform sampler2D noise;
uniform float scroll_speed;
uniform vec3 emissive_color: source_color;
uniform float emissive_boost;
uniform float cursor_fade_max_distance = 100;
uniform vec3 cursor_position;

varying vec2 animated_uv;
varying vec3 cell_color;
varying vec3 world_pos;


void vertex() {
	// Scrolling UVs
	animated_uv = UV;
	animated_uv.y += TIME * scroll_speed;
	
	// Get world position
	vec4 world_vertex = MODEL_MATRIX * vec4(VERTEX, 1.0);
	world_pos = world_vertex.xyz;
	
	// Pass custom data
	cell_color = COLOR.rgb;
	//cell_color = vec3(1.0,0.0,0.0);
}

void fragment() {
	float base_alpha = pow(mod(UV.y, 0.25), 3.0);
	float edge_alpha_y = clamp(pow(mod(UV.y, 0.25), 1.5) + base_alpha, 0.0, 1.0);
	float edge_alpha_x = 1.0;
	
	// Side edge fades
	if(UV.x >= 0.8)
	{
		float t = (UV.x - 0.8) / 0.2;
		edge_alpha_x = 1.0 - t;
	}
	else if(UV.x <= 0.2)
	{
		float t = UV.x / 0.2;
		edge_alpha_x = t;
	}
	
	// cursor distance fade
	float distance_fade = pow(1.0 - clamp(distance(world_pos.xz, cursor_position.xz) / cursor_fade_max_distance, 0.0, 1.0), 2.0);
	//float distance_fade = 1.0;
	
	ALPHA = texture(noise, animated_uv).r * edge_alpha_y * edge_alpha_x * distance_fade;
	ALBEDO = cell_color.rgb;
	EMISSION = cell_color.rgb * emissive_boost;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
