float blur(in sampler2D tex, in vec2 texCoord, in vec2 resolution) {
    float sum = 0.;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++){
            sum += texture(tex, texCoord + vec2(i, j) / resolution).x;
        }
    }
    return sum / 9.;
}