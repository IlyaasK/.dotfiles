precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // Almost eliminate blue light
    color.b = color.b * 0.25;
    
    // Boost red significantly for deep orange/amber
    color.r = min(1.0, color.r * 1.3);
    
    // Reduce green slightly to shift from yellow to orange
    color.g = color.g * 0.85;
    
    gl_FragColor = color;
}
