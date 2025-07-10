precision mediump float;

attribute vec3 position;
attribute vec3 normal;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

varying vec3 vNormal;
varying vec3 vFragPos;

void main() {
    // Convert to world space
    vec4 worldPos = modelMatrix * vec4(position, 1.0);
    vFragPos = worldPos.xyz;

    // Correctly transformed normal
    vNormal = normalize(normalMatrix * normal);

    // Project to screen space
    gl_Position = projectionMatrix * viewMatrix * worldPos;
}
