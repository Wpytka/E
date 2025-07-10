varying vec2 vUvs; 
varying vec3 v_normal;
varying vec3 v_worldPosition;
varying vec3 v_viewDirection;

void main() {
  vec4 localPosition = vec4(position, 1.0);

  vUvs = uv;

  vec4 worldPos = modelViewMatrix * vec4(position, 1.0);
  v_worldPosition = worldPos.xyz;
  v_normal = normalize(normalMatrix * normal);

  v_viewDirection = normalize(cameraPosition - v_worldPosition);

  gl_Position = projectionMatrix * modelViewMatrix * localPosition;
}