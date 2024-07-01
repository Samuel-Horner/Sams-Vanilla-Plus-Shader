//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#include "/lib/texture_formats.glsl"
#define CLOUD_FOG
#include "/lib/fog.glsl"

in vec2 texCoord;
in vec2 lightCoord;
in vec4 glColor;

in float vertexDistance;

uniform sampler2D gtexture;
uniform sampler2D lightmap;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 pixelColor;

void main() {
    vec4 texColor = texture(gtexture, texCoord);
    if (texColor.a < 0.1) discard;
    
    vec4 lightColor = texture(lightmap, lightCoord);

    vec4 finalColor = texColor * lightColor * glColor;

    pixelColor = applyFog(finalColor, vertexDistance);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;
out vec2 lightCoord;
out vec4 glColor;

out float vertexDistance;

void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glColor = gl_Color;
    vertexDistance = length((gl_ModelViewMatrix * gl_Vertex).xyz);
}

#endif
