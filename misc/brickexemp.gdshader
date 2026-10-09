shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

instance uniform bool active = false;

void fragment() {
    ALBEDO = active ? vec3(0.1, 1.0, 0.1) : vec3(1.0);
    ALPHA = 0.5;
}