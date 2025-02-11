//Common//
#include "/lib/common.glsl"
#define NO_SHADING
#include "/lib/lighting.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#include "/lib/texture_formats.glsl"

uniform sampler2D colortex0;

in vec2 texCoord;
in vec4 glColor;
in vec2 lightCoord;
in float vertexDistance;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 pixelColor;

void main() {
    vec4 color = texture(colortex0, texCoord) * glColor;
    if (color.a < 0.1) discard;
    calcLighting(lightCoord, color, vertexDistance);
    pixelColor = color;
}
#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec4 glColor;
out vec2 lightCoord;
out float vertexDistance;

void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glColor = gl_Color;
    lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vertexDistance = length((gl_ModelViewMatrix * gl_Vertex).xyz);
}

#endif
