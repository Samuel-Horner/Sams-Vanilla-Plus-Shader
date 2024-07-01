//Common//
#include "/lib/common.glsl"
#include "/lib/lighting.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#include "/lib/texture_formats.glsl"
#include "/lib/fog.glsl"

uniform sampler2D gtexture;

in vec2 texCoord;
in vec2 lightCoord;
in vec4 glColor;
in vec4 shadowPos;
in float vertexDistance;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 pixelColor;

void main() {
    vec4 texColor = texture(gtexture, texCoord);
    if (texColor.a < 0.1) discard;
    
    vec4 color = texColor * glColor;

    calcLighting(shadowPos, vertexDistance, lightCoord, vertexDistance, color);

    pixelColor = applyFog(color, vertexDistance);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec2 lightCoord;
out vec4 glColor;
out float vertexDistance;
out vec4 shadowPos;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glColor = gl_Color;

    calcShadows(shadowPos, lightCoord);
    
    vertexDistance = length((gl_ModelViewMatrix * gl_Vertex).xyz);
    gl_Position = ftransform();
}

#endif
