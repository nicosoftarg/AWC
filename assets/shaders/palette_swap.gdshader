shader_type canvas_item;

uniform sampler2D palette_from : source_color;
uniform sampler2D palette_to   : source_color;
uniform int palette_size : hint_range(1, 64) = 8;
uniform float tolerance : hint_range(0.01, 0.5) = 0.01;

void fragment() {
    vec4 src = texture(TEXTURE, UV);
    vec4 final_color = src;

    for (int i = 0; i < palette_size; i++) {
        float u = (float(i) + 0.5) / float(palette_size);

        vec3 from_color = texture(palette_from, vec2(u, 0.5)).rgb;
        vec3 to_color   = texture(palette_to,   vec2(u, 0.5)).rgb;

        if (distance(src.rgb, from_color) < tolerance) {
            final_color = vec4(to_color, src.a);
            break;
        }
    }

    COLOR = final_color;
}
