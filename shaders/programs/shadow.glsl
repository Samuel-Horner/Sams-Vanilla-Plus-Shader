//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

#include "/lib/texture_formats.glsl"

uniform sampler2D gtexture;

in vec2 texCoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 pixelColor;

void main() {
	pixelColor = texture(gtexture, texCoord);
	if (pixelColor.a < 0.1) discard;
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

#include "/lib/distort.glsl"

out vec2 texCoord;

void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();
	gl_Position.xyz = distort(gl_Position.xyz);
}

#endif
