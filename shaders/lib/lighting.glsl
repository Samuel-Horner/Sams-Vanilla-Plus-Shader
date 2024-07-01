#include "/lib/distort.glsl"

#ifdef FRAGMENT_SHADER

uniform sampler2D shadowtex0;
uniform sampler2D lightmap;

#ifdef DYNAMICLIGHT
uniform int heldItemId;
uniform int heldItemId2;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
#endif

#ifdef SMOOTH_SHADOWS
uniform sampler2D noisetex;

const int shadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int totalSamples = shadowSamplesPerSize * shadowSamplesPerSize;
#endif
const float maxLightLevel = 1. - 1./32.;

float getShadow(in vec3 sampleCoords, in sampler2D tex){
    #ifdef SMOOTH_SHADOWS
        float randomAngle = texture2D(noisetex, sampleCoords.xy * 20.).r * 100.;
        float cosTheta = cos(randomAngle);
        float sinTheta = sin(randomAngle);
        mat2 rotation =  mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;
        float shadowAccum = 0.;
        for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++){
            for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++){
                vec2 offset = rotation * vec2(x, y);
                vec3 currentSampleCoordinate = vec3(sampleCoords.xy + offset, sampleCoords.z);
                float shadowMapDepth = texture2D(tex, currentSampleCoordinate.xy).r;
                shadowAccum += shadowMapDepth < currentSampleCoordinate.z ? smoothstep(-SHADOW_BRIGHTNESS, 1., shadowMapDepth) : 1.0;
            }
        }
        return shadowAccum / totalSamples;
    #else
        float shadowMapDepth = texture2D(tex, sampleCoords.xy).r;
        return shadowMapDepth < sampleCoords.z ? smoothstep(-SHADOW_BRIGHTNESS, 1., shadowMapDepth) : 1.0;
    #endif
}

void calcLighting(in vec4 shadowPos, in vec2 lm, in float vertexDistance, inout vec4 color) {
    float all_shadow = getShadow(shadowPos.xyz, shadowtex0);
    #ifdef DYNAMICLIGHT
    int lightLevel = 0;
    if (heldItemId == 44000 || heldItemId2 == 44000){
        lightLevel = 14;
    } else {
        lightLevel = max(heldBlockLightValue, heldBlockLightValue2);
    }
    if (lightLevel > 0){
        float radius = DYNAMICLIGHT_RADIUS * (lightLevel / 15.);
        if (vertexDistance < radius) {
            lm.x += (maxLightLevel) * ((radius - vertexDistance) / radius) * (lightLevel / 15.);
            if (lm.x > maxLightLevel) lm.x = maxLightLevel;
        }
    }
    #endif
    color *= vec4(texture(lightmap, lm).xyz * pow(all_shadow, pow(1. - lm.x, 2.2)), 1.);
}

#endif

#ifdef VERTEX_SHADER

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

void calcShadows(out vec4 shadowPos, inout vec2 lightCoord) {
    float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 playerPos = gbufferModelViewInverse * viewPos;
    shadowPos = shadowProjection * (shadowModelView * playerPos);
    float bias = computeBias(shadowPos.xyz);
    shadowPos.xyz = distort(shadowPos.xyz);
    shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;
    vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
    shadowPos.xyz += normal.xyz / normal.w * bias;
    shadowPos.w = lightDot;
}  
#endif
