#version 460 core
out vec4 FragColor;
  
in vec2 uv;

// Settings
float pointSpreadDistance = .1;
float pointOffsetRandomness = .05;
float uvUG = 10;
vec2 biomePointOffset = vec2(0, 0);

float xSlice = 100;
float ySlice = 10;
float xFallOffSizeIncrease = 10;
float yFallOffSizeIncrease = 10;

float randomnessScale = 0.0;

float resolution = 10;
float noiseScale = .025;
int noiseSteps = 10;

float stepPow = 1.5;

float fallOffScale = 1.5;
float noisefalloff(float i)
{
    return fallOffScale/(i+fallOffScale);
}

float maxdistance = sqrt(pointSpreadDistance * pointSpreadDistance * 2);

float alphatorange(float val)
{
    return (val-0.5f)*2;
}

float random(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 alterSeed(vec2 seed)
{
    float xval = random(seed);
    return vec2(xval, random(vec2(xval, seed.x)));
}

float round(float val)
{
    return floor(val + 0.5f);
}

vec2 getAproxPoint(vec2 position)
{
    return vec2(
        round(position.x/pointSpreadDistance), 
        round(position.y/pointSpreadDistance)
    );
}

vec2[9] surroundingPoints(vec2 point)
{
    vec2 points[9];
    points[0] = vec2(point.x, point.y);
    points[1] = vec2(point.x, point.y+1);
    points[2] = vec2(point.x, point.y-1);

    points[3] = vec2(point.x+1, point.y);
    points[4] = vec2(point.x+1, point.y+1);
    points[5] = vec2(point.x+1, point.y-1);

    points[6] = vec2(point.x-1, point.y);
    points[7] = vec2(point.x-1, point.y+1);
    points[8] = vec2(point.x-1, point.y-1);

    return points;
}

vec2 getPointPosition(vec2 pointId)
{
    vec2 secondseed = alterSeed(pointId);
    return vec2(
        pointId.x*pointSpreadDistance + alphatorange(random(pointId))*pointOffsetRandomness, 
        pointId.y*pointSpreadDistance + alphatorange(random(secondseed))*pointOffsetRandomness
    );
}

vec3 mod289(vec3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+10.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(vec3 P)
{
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

float steppingNoise(vec2 vec, float resolution, float slice, float _step, int steps, float stepPow)
{
    float n = 0;
    for (int i = 0; i < steps; i++)
    {
        n += cnoise(vec3(vec*resolution * pow(stepPow, i) - _step*i, slice));
    }
    return n;
}


void main()
{
    // Getting Point
    vec2 uvOffset = vec2(0, 0);
    float n = 0;
    
    vec2 _step = vec2(1.3, 1.7);
    for (int i = 0; i < noiseSteps; i++)
    {
        uvOffset += vec2(
            cnoise(vec3(uv*resolution * pow(stepPow, i) - _step*i, xSlice)),
            cnoise(vec3(uv*resolution * pow(stepPow, i) - _step*i, ySlice))
            )*noiseScale*noisefalloff(i);
    }

    uvOffset += vec2(random(uv), random(alterSeed(uv)))*randomnessScale;

    vec2 nuv = uv;//+uvOffset;
    vec2 aproxCenterPoint = getAproxPoint(nuv);

    vec2 surroundingPoints[9] = surroundingPoints(aproxCenterPoint);
    int closest = 0;
    float smallestdistance = distance(nuv, getPointPosition(surroundingPoints[0]));
    for (int i = 1; i < 9; i++)
    {
        float _distance = distance(nuv, getPointPosition(surroundingPoints[i])) + steppingNoise(uv, 10, i*10, 2)
        if (distance(nuv, getPointPosition(surroundingPoints[i])) < smallestdistance)
        {
            closest = i;
            smallestdistance = distance(nuv, getPointPosition(surroundingPoints[i]));
        }
    }

    vec2 redSeed = alterSeed(surroundingPoints[closest]);
    vec2 greenSeed = alterSeed(redSeed);
    vec2 blueSeed = alterSeed(greenSeed);
    FragColor = vec4(random(redSeed), random(greenSeed), random(blueSeed), 1.0f);
}