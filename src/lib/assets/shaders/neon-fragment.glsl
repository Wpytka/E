#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec3 u_cameraPosition;

// These should be passed from the vertex shader
varying vec3 v_worldPosition;
varying vec3 v_normal;
varying vec2 vUvs;

// Noise function for texture variation
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// 3D noise function
float noise3D(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

// Fresnel effect for rim lighting
float fresnel(vec3 normal, vec3 viewDir, float power) {
    float dot_product = dot(normalize(normal), normalize(viewDir));
    return pow(1.0 - abs(dot_product), power);
}

void main() {
    // Calculate view direction
    vec3 viewDir = normalize(u_cameraPosition - v_worldPosition);
    
    // Normalize the normal
    vec3 normal = normalize(v_normal);
    
    // Pulsating time factor
    float pulse = sin(u_time * 2.0) * 0.3 + 0.7;
    
    // Neon color
    vec3 neonColor = vec3(0.700, 0.108, 0.014);
    
    // Initialize color
    vec3 color = vec3(0.0);
    
    // Base neon glow intensity
    float baseIntensity = 2.0;
    
    // Add noise texture for surface variation - very large scale
    float noiseValue = noise(vUvs * 0.8 + u_time * 0.5);
    float noise3DValue = noise3D(v_worldPosition * 0.3 + u_time * 0.3);
    float textureVariation = 0.85 + noiseValue * 0.15 + noise3DValue * 0.1;
    
    // Core glow based on UV coordinates (creates variation across surface)
    float uvGlow = 1.0 - length(vUvs - 0.5) * 80.8;
    uvGlow = max(uvGlow, 0.3); // Ensure minimum glow
    
    // Fresnel rim lighting effect
    float rimIntensity = fresnel(normal, viewDir, 2.0);
    float rimGlow = rimIntensity * 2.5;
    
    // Combine base glow with surface variation
    float surfaceGlow = (baseIntensity + uvGlow * 0.6) * textureVariation * pulse;
    
    // Main surface color
    color = neonColor * surfaceGlow * 1.2;
    
    // Add bright rim lighting
    color += neonColor * rimGlow * 1.5;
    
    // Add flickering effect
    float flicker = sin(u_time * 12.0) * 0.1 + sin(u_time * 25.0) * 0.05;
    color *= (1.0 + flicker);
    
    // Add subtle pulsing based on world position - very large wavelength
    float worldPulse = sin(v_worldPosition.x * 0.5 + u_time * 3.0) * 0.05 + 
                       sin(v_worldPosition.y * 0.7 + u_time * 2.0) * 0.04;
    color *= (1.0 + worldPulse);
    
    // Add depth-based intensity variation - very large waves
    float depthFactor = 1.0 + sin(v_worldPosition.z * 0.8 + u_time) * 0.08;
    color *= depthFactor;
    
    // Enhanced rim glow for edges
    float edgeGlow = pow(rimIntensity, 0.5) * 1.8;
    color += neonColor * edgeGlow * pulse;
    
    // Enhance contrast and saturation
    color = pow(color, vec3(0.8));
    
    // Ensure minimum brightness
    color = max(color, neonColor * 0.1);
    
    gl_FragColor = vec4(color, 1.0);
}