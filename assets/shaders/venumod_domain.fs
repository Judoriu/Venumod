
extern number time;
extern number overlay_alpha;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
{
    // Coordonnées centrées et adaptées à l'écran
    vec2 p = uv - vec2(0.5);
    p.x *= love_ScreenSize.x / love_ScreenSize.y;

    float t = time;
    float dist = length(p);
    float angle = atan(p.y, p.x);

    // Couleurs du domaine
    vec3 deep = vec3(0.008, 0.003, 0.035);
    vec3 purple = vec3(0.20, 0.025, 0.52);
    vec3 violet = vec3(0.48, 0.12, 0.95);
    vec3 blue = vec3(0.035, 0.16, 0.55);
    vec3 white = vec3(0.75, 0.70, 1.0);

    // Nuages d'énergie mouvants
    float clouds = sin(p.x * 13.0 + t * 0.7)
                 * cos(p.y * 17.0 - t * 0.5);

    clouds += sin((p.x + p.y) * 20.0 + t);
    clouds *= 0.5;

    // Spirale spatiale
    float spiral = sin(angle * 7.0 + dist * 35.0 - t * 2.0);
    spiral *= smoothstep(0.9, 0.05, dist);

    // Ondes concentriques
    float waves = sin(dist * 75.0 - t * 4.0);
    waves = pow(max(waves, 0.0), 8.0);

    // Anneaux lumineux
    float rings = sin(dist * 32.0 - t * 1.8);
    rings = smoothstep(0.75, 0.98, rings);

    // Noyau lumineux
    float core = exp(-dist * 9.0);

    // Énergie globale
    float energy = clouds * 0.22
                 + spiral * 0.18
                 + waves * 0.35;

    vec3 result = mix(deep, purple, 0.45 + energy);
    result = mix(result, blue, 0.25 + clouds * 0.15);
    result += violet * rings * 0.35;
    result += white * core * 0.35;

    // Particules lumineuses
    vec2 grid = uv * vec2(65.0, 45.0);
    vec2 cell = floor(grid);
    vec2 local = fract(grid) - 0.5;

    float randomValue = fract(
        sin(dot(cell, vec2(12.9898, 78.233)))
        * 43758.5453
    );

    float star = smoothstep(
        0.045,
        0.0,
        length(local)
    );

    float twinkle = 0.5 + 0.5 * sin(t * 3.0 + randomValue * 30.0);

    star *= step(0.94, randomValue) * twinkle;

    result += white * star * 1.5;

    // Lueurs radiales
    float glow = exp(-abs(sin(dist * 45.0 - t * 2.0)) * 8.0);
    result += violet * glow * 0.12;

    // Fondu vers les bords
    float vignette = 1.0 - smoothstep(0.35, 0.85, dist);
    result *= 0.65 + vignette * 0.35;

    return vec4(result, overlay_alpha) * color;
}
