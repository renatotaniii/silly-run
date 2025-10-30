shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D noise_texture;
uniform float noise_strength = 0.5;
uniform float noise_speed = 0.2;

void vertex() {
    // Offset the vertices to create a wavy surface
    vec2 noise_uv = UV + TIME * noise_speed;
    float height = texture(noise_texture, noise_uv).x;
    VERTEX += NORMAL * height * noise_strength;
}

void fragment() {
    // Fresnel effect for edge opacity
    vec3 view_dir = normalize(VIEW);
    float fresnel = 1.0 - dot(NORMAL, view_dir);

    // Bubble color and base transparency
    vec3 bubble_color = vec3(0.7, 0.9, 1.0);
    float alpha = fresnel * 0.75; // More opaque at the edges

    // Iridescence effect using Fresnel and reflection
    vec3 reflection = reflect(view_dir, NORMAL);
    vec3 iridescent = vec3(0.0);
    iridescent.r = abs(sin(reflection.x * 5.0 + TIME));
    iridescent.g = abs(sin(reflection.y * 5.0 + TIME));
    iridescent.b = abs(sin(reflection.z * 5.0 + TIME));
    iridescent = iridescent * fresnel;

    // Output the final color
    ALBEDO = bubble_color;
    ALPHA = alpha;
    EMISSION = iridescent * 0.25; // Subtle iridescence glow
    ROUGHNESS = 0.0; // Make it very reflective
    METALLIC = 0.5;
}