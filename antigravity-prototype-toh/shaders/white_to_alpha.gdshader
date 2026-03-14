shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float threshold : hint_range(0.0, 1.0) = 0.95;

void fragment() {
	vec4 color = texture(texture_albedo, UV);
	// Check if the color is close to white
	float avg = (color.r + color.g + color.b) / 3.0;
	if (avg > threshold && color.r > threshold && color.g > threshold && color.b > threshold) {
		discard;
	}
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
