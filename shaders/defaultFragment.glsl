#version 460 core
out vec4 FragColor;
  
in vec3 pos;

// Settings
float pointSpreadDistance = .1;
float pointOffsetRandomness = .05;
vec2 biomePointOffset = vec2(0, 0);

float random(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 alterSeed(vec2 seed)
{
    float xval = random(seed);
    return vec2(xval, random(vec2(xval, seed.x)));
}

// vec2 getPositionFromPoint(vec2 point)
// {
//     return vec2(pointSpreadDistance)
// }

// vec2 getPointFromPosition(vec2 position)
// {
//     return vec2()
// }

void main()
{
    // Normalizing Position
    vec2 rpos = vec2((pos.x+1)/2, (pos.y+1)/2);

    vec2 seed = rpos;
    for (int i = 0; i < 50; i++)
    {
        seed = alterSeed(seed);
    }

    float colorVal = random(vec2(seed));

    FragColor = vec4(colorVal, colorVal, colorVal, 1.0f);
}