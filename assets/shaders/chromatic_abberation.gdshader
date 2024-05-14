shader_type canvas_item;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment()
{
	vec4 current = texture(TEXTURE, UV);
	vec4 r_displaced = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE*r_displacement), 0.0);
	vec4 g_displaced = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE*g_displacement), 0.0);
	vec4 b_displaced = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE*b_displacement), 0.0);
	float alpha_sum = min(1.0, current.a + r_displaced.a + g_displaced.a + b_displaced.a);
	
	COLOR = vec4(r_displaced.r, g_displaced.g, b_displaced.b, alpha_sum);
}
