#ifndef MAGICRP_SURFACE_INCLUDED
#define MAGICRP_SURFACE_INCLUDED

struct Surface
{
    float3 position;
    float3 normal;
    float3 viewDirection;
    float depth;
    half3 color;
    half alpha;
    float metallic;
    float smoothness;
    float dither;
};

#endif