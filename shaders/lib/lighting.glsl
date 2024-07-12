#include "/lib/distort.glsl"

#ifdef FRAGMENT_SHADER

uniform sampler2D shadowtex0;
uniform sampler2D lightmap;

#ifndef NO_SHADING
uniform int worldTime;
uniform int worldDays;

const int sunrise = -1000;
const int use_day_min = 24000 + sunrise;
#endif

#ifdef DYNAMICLIGHT
uniform int heldItemId;
uniform int heldItemId2;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;

const float maxLightLevel = 1. - 1./32.;
#endif

#ifdef SMOOTH_SHADOWS
uniform sampler2D noisetex;

const int shadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int totalSamples = shadowSamplesPerSize * shadowSamplesPerSize;
#endif

#ifndef NO_SHADING
float getShadow(in vec4 sampleCoords, in sampler2D tex){
    #ifdef NO_SHADOWS
    return 1.;
    #endif
    if (sampleCoords.w > 0.001){
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
                    shadowAccum += shadowMapDepth < currentSampleCoordinate.z ? SHADOW_BRIGHTNESS : 1.;
                }
            }
            return shadowAccum / totalSamples;
        #else
            float shadowMapDepth = texture2D(tex, sampleCoords.xy).r;
            return shadowMapDepth < sampleCoords.z ? SHADOW_BRIGHTNESS : 1.;
        #endif
    } else {
        return SHADOW_BRIGHTNESS;
    }
}
#endif

#ifndef NO_SHADING
void calcLighting(in vec4 shadowPos, in float vertexDistance, in vec2 lm, inout vec4 color) {
#else
void calcLighting(in vec2 lm, inout vec4 color, in float vertexDistance) {
#endif
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
    #ifndef NO_SHADING
    float night_level = worldTime < use_day_min && worldTime > 6000 ? smoothstep(13000., 14000., float(worldTime)) : 1. - smoothstep(0., 1000., float((worldTime - sunrise) % 24000)); // 1 when night 0 when not
    float all_shadow = mix(getShadow(shadowPos, shadowtex0), SHADOW_BRIGHTNESS, night_level);
    color *= vec4(texture(lightmap, lm).xyz * pow(all_shadow, pow(1. - lm.x, 2.2)), 1.);
    #else
    color *= vec4(texture(lightmap, lm).xyz, 1.);
    #endif
}

#endif

#ifdef VERTEX_SHADER
#ifndef NO_SHADING

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 sunPosition;

void calcShadows(out vec4 shadowPos) {
    #ifdef NO_SHADOWS
    shadowPos = vec4(0.);
    return;
    #endif
    float lightDot = dot(normalize(sunPosition), normalize(gl_NormalMatrix * gl_Normal));
    if (lightDot > 0.){
        vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
        vec4 playerPos = gbufferModelViewInverse * viewPos;
        shadowPos = shadowProjection * (shadowModelView * playerPos);
        float bias = computeBias(shadowPos.xyz);
        shadowPos.xyz = distort(shadowPos.xyz);
        shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;
        vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
        shadowPos.xyz += normal.xyz / normal.w * bias;
        shadowPos.w = lightDot;
    } else {
        shadowPos = vec4(0.);
    }
}
#endif
#endif