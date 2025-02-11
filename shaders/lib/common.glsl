const float sunPathRotation = -40; // [-40 -30 -20 -10 0 10 20 30 40]

// #define NO_SHADOWS
const int shadowMapResolution = 1024; // [128 256 512 1024 2048 4096 8192]
#define SHADOW_DISTORT_FACTOR 0.1 // [0.1 0.25 0.5 0.75 1.0]
#define SHADOW_BIAS 1.00 // [0.00 0.01 0.10 0.15 0.20 0.25 0.30 0.50 0.75 1.00 1.50 2.00 2.50 3.00 3.50 4.00 4.50 5.00 6.00 7.00 8.00 9.00 10.00]
#define SMOOTH_SHADOWS
#define SHADOW_SAMPLES 2 // [2 4 6 8]
#define SHADOW_BRIGHTNESS 0.7 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define DYNAMICLIGHT
#define DYNAMICLIGHT_RADIUS 8 // [4 5 6 7 8 9 10 11 12 13 14 15 16]

#define FOG