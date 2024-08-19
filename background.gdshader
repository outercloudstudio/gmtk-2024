shader_type canvas_item;

uniform float danger = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec4 light = vec4(20.0 / 255.0, 16.0 / 255.0, 19.0 / 255.0, 1.0);
	vec4 light_danger = vec4(115.0 / 255.0, 23.0 / 255.0, 45.0 / 255.0, 1.0);
	vec4 dark = vec4(6.0 / 255.0, 6.0 / 255.0, 8.0 / 255.0, 1.0);
	vec4 dark_danger = vec4(59.0 / 255.0, 23.0 / 255.0, 37.0 / 255.0, 1.0);
	
	//vec2 grid_position = vec2(UV.x * cos(PI / 4.0), UV.y * sin(PI / 4.0)) * 1000.0 / 4.0;
	//vec2 grid_position = vec2(UV.x, UV.y) * 1000.0 / 4.0;
	
	//COLOR = vec4(floor(mod(grid_position / 2.0, 2.0)), 0.0, 1.0);
	//COLOR = vec4(mod(grid_position / 2.0, 2.0), 0.0, 1.0);
	
	vec2 animated_uv = UV + TIME / 1000.0 * 10.0;
	
	float angle = atan(animated_uv.y / animated_uv.x);
	float dist = length(animated_uv);
	float new_angle = angle - PI / 4.0;
	vec2 rotated_UV = dist * vec2(cos(new_angle),sin(new_angle));
	
	float size = 1000.0 / 8.0;
	
	vec2 grid_position_uv = floor(rotated_UV * size) / size;
	vec2 grid_position = grid_position_uv * size;
	vec2 mod_grid_position = mod(grid_position, 2.0);
	
	bool odd = mod_grid_position.x != mod_grid_position.y;
	
	if(odd) {
		COLOR = mix(dark, dark_danger, danger);
	} else {
		COLOR = mix(light, light_danger, danger);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
