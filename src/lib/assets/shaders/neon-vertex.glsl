
// Input attributes
layout(location = 0) in vec3 a_position;
layout(location = 1) in vec3 a_normal;
layout(location = 2) in vec2 a_uv;

// Uniform matrices
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;
uniform mat3 u_normalMatrix; // Inverse transpose of model matrix
uniform vec3 u_viewPosition; // Camera world position

// Output to fragment shader
varying vec2 v_uv;
varying vec3 vNormal;
varying vec3 v_worldPos;
varying vec3 v_viewPos;

void main() {
    // Transform position to world space
    vec4 worldPos = u_model * vec4(a_position, 1.0);
    v_worldPos = worldPos.xyz;
    
    // Transform normal to world space
    v_normal = normalize(u_normalMatrix * a_normal);
    
    // Pass through UV coordinates
    v_uv = a_uv;
    
    // Pass camera position
    v_viewPos = u_viewPosition;
    
    // Calculate final vertex position
    gl_Position = u_projection * u_view * worldPos;
}