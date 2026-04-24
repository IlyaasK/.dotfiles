precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // First grayscale
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec4 grayColor = vec4(vec3(gray), color.a);
    
    // Then apply deep orange filter
    grayColor.b = grayColor.b * 0.2;  // Almost eliminate blue
    grayColor.r = min(1.0, grayColor.r * 1.35);  // Heavy red emphasis
    grayColor.g = grayColor.g * 0.8;  // Reduced green to shift from yellow to orange
    
    gl_FragColor = grayColor;
}
