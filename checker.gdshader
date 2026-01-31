shader_type spatial;

void fragment() {
    // Create a 10x10 checkerboard pattern based on UVs
    vec2 uv = floor(UV * 10.0);
    float checker = mod(uv.x + uv.y, 2.0);
    ALBEDO = vec3(checker); // Alternates between 0 (black) and 1 (white)
}
