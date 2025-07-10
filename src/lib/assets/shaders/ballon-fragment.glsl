
#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec3 u_lightPosition;
uniform vec3 u_color;

varying vec3 v_normal;
varying vec3 v_worldPosition;
varying vec3 v_viewDirection;
varying vec2 vUvs;

// Noise function for surface texture
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth noise
float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(
        mix(noise(i), noise(i + vec2(1.0, 0.0)), f.x),
        mix(noise(i + vec2(0.0, 1.0)), noise(i + vec2(1.0, 1.0)), f.x),
        f.y
    );
}

// Fresnel effect
float fresnel(vec3 viewDir, vec3 normal, float power) {
    return pow(1.0 - max(dot(viewDir, normal), 0.0), power);
}

void main() {
    // Normalize interpolated normal
    vec3 normal = normalize(v_normal);
    vec3 viewDir = normalize(v_viewDirection);
    
    // Light direction (can be animated or fixed)
    vec3 lightPos = u_lightPosition + vec3(
        cos(u_time * 0.5) * 2.0,
        sin(u_time * 0.3) * 1.5,
        sin(u_time * 0.2) * 1.0
    );
    vec3 lightDir = normalize(lightPos - v_worldPosition);
    
    vec3 baseColor = u_color;
    
    // Add subtle surface texture using UV coordinates
    float surfaceNoise = smoothNoise(vUvs * 20.0) * 0.02;
    baseColor += surfaceNoise;
    
    // Diffuse lighting
    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = baseColor * (NdotL * 0.7);
    
    // Specular reflection (very shiny)
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 64.0);
    vec3 specular = vec3(1.0) * spec * 0.9;
    
    // Additional specular highlight for extra shininess
    float spec2 = pow(max(dot(viewDir, reflectDir), 0.0), 16.0);
    specular += vec3(1.0) * spec2 * 0.3;
    
    // Fresnel rim lighting
    float rim = fresnel(viewDir, normal, 4.0);
    vec3 rimColor = vec3(0.8, 0.9, 1.0) * rim * 0.1;
    
    // Environmental reflection (fake)
    vec2 envUV = v_worldPosition.xy * 0.5 + 0.5;
    float envReflection = smoothNoise(envUV * 4.0 + u_time * 0.1) * 0.2;
    vec3 envColor = vec3(0.3, 0.6, 0.9) * envReflection;
    
    // Subsurface scattering effect
    float backLight = max(dot(normal, -lightDir), 0.0);
    vec3 subsurface = baseColor * backLight * 0.2;
    
    // Combine all lighting components
    vec3 finalColor = diffuse + specular + rimColor + envColor + subsurface;
    
    // Add ambient lighting
    finalColor += baseColor * 0.2;
    
    // Enhance saturation for rubber look
    finalColor = mix(vec3(dot(finalColor, vec3(0.299, 0.587, 0.114))), finalColor, 1.5);
    
    // Final color adjustment
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    gl_FragColor = vec4(finalColor, 1.0);
}