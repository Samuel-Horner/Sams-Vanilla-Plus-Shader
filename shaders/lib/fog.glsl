#ifdef FOG
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;
#endif

vec4 applyFog(in vec4 color, in float vertexDistance){
    #ifdef FOG
        float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
        #ifndef CLOUD_FOG
            return vec4(mix(color.xyz, fogColor, fogValue), color.a);
        #else
            return vec4(mix(color.xyz, fogColor, fogValue), color.a - fogValue);
        #endif
    #else
        return color;
    #endif
} 