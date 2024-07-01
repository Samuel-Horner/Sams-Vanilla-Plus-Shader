//////////////////////////////////////////////////
// A3Shaders (template file from Complementary) //
//////////////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#include "/lib/texture_formats.glsl"

#define DISPLAY_SHADOW_MAP 0 // [0 1]

in vec2 texCoord;

#if DISPLAY_SHADOW_MAP == 0
    uniform sampler2D colortex0;
#elif DISPLAY_SHADOW_MAP == 1
    uniform sampler2D shadowtex0;
#endif

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 pixelColor;

void main() {
    #if DISPLAY_SHADOW_MAP == 0
        pixelColor = texture(colortex0, texCoord);
    #elif DISPLAY_SHADOW_MAP == 1
        pixelColor = texture(shadowtex0, texCoord);
    #endif
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;

void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
