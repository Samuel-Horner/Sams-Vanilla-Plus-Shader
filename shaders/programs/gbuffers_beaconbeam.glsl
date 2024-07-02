//Common//
#include "/lib/common.glsl"
#define NO_SHADING
#include "/lib/lighting.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#include "/lib/texture_formats.glsl"

uniform sampler2D colortex0;
uniform int isEyeInWater;

in vec2 texCoord;
in vec4 glColor;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 pixelColor;

void main() {
    if (isEyeInWater == 1) discard;
    vec4 color = texture(colortex0, texCoord) * glColor;
    if (color.a < 0.1) discard;
    pixelColor = color;
}
#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec4 glColor;

void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glColor = gl_Color;
}

#endif
