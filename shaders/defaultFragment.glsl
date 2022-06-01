#version 460 core
out vec4 FragColor;
  
in vec3 pos;

// Settings
float pointSpreadDistance = .25;
vec2 positionOffset = vec2(0, 0);

float random(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float test(int i)
{
    return i;
}

void main()
{
    // Normalizing Position
    vec2 rpos = vec2((pos.x+1)/2, (pos.y+1)/2);

    float colorVal = pNoise(vec2(rpos.x*10, rpos.y*10), 10000);

    FragColor = vec4(colorVal, colorVal, colorVal, 1.0f);
}