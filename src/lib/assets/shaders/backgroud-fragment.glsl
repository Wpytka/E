
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;   // Screen resolution
uniform vec3 u_gridColor;    // RGB color for the grid lines
uniform float u_gridSpacing; // Spacing between grid lines (e.g., 20.0)
uniform float u_lineThickness; // Thickness of the grid lines (e.g., 0.5)
uniform vec3 u_backgroundColor;
//uniform float gridOpacity = 1.0; 

uniform float uTime;
varying vec2 vUvs;

void main() {

// Calculate grid coordinates
    vec2 gridUV = vUvs / u_gridSpacing;
    
    // Calculate screen-space derivatives to maintain consistent line thickness
    vec2 gridDX = dFdx(gridUV);
    vec2 gridDY = dFdy(gridUV);

    vec2 pixelSize = sqrt(gridDX * gridDX + gridDY * gridDY);

    vec2 gridLines = abs(fract(gridUV) - 0.5);

    vec2 thickness = u_lineThickness * pixelSize;

    float aaRange = max(pixelSize.x, pixelSize.y) * 0.5;

    float gridX = 1.0 - smoothstep(thickness.x * 0.5 - aaRange, thickness.x * 0.5 + aaRange, gridLines.x);
    float gridY = 1.0 - smoothstep(thickness.y * 0.5 - aaRange, thickness.y * 0.5 + aaRange, gridLines.y);
    

    float gridMask = max(gridX, gridY);

    vec3 finalColor = mix(u_backgroundColor, u_gridColor, gridMask);

    gl_FragColor = vec4(finalColor, 1);
}