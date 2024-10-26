#ifndef MAGICRP_LIT_PASS_INCLUDED
#define MAGICRP_LIT_PASS_INCLUDED

#if defined(LIGHTMAP_ON)
#define GI_ATTRIBUTE_DATA float2 lightMapUV : TEXCOORD1;
#define GI_VARYINGS_DATA float2 lightMapUV : VAR_LIGHT_MAP_UV;
#define TRANSFER_GI_DATA(input, output) output.lightMapUV = input.lightMapUV * unity_LightmapST.xy + unity_LightmapST.zw;
#define GI_FRAGMENT_DATA(input) input.lightMapUV
#else
#define GI_ATTRIBUTE_DATA
#define GI_VARYINGS_DATA
#define TRANSFER_GI_DATA(input, output)
#define GI_FRAGMENT_DATA(input) 0.0
#endif

#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Shadows.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/BRDF.hlsl"
#include "../ShaderLibrary/GI.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float2 baseUV : TEXCOORD0;
    float3 normalOS : NORMAL;
    GI_ATTRIBUTE_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    GI_VARYINGS_DATA
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings LitPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    TRANSFER_GI_DATA(input, output);

    output.uv = TransformBaseUV(input.baseUV);
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    return output;
}

half4 LitPassFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);

    half4 base = GetBase(input.uv);
    #ifdef _CLIPPING
    clip(base.a - GetCutoff(input.uv));
    #endif

    Surface surface;
    surface.position = input.positionWS;
    surface.color = base.rgb;
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    surface.depth = -TransformWorldToView(input.positionWS).z;
    surface.alpha = base.a;
    surface.normal = normalize(input.normalWS);
    surface.metallic = GetMetallic(input.uv);
    surface.smoothness = GetSmoothness(input.uv);
    surface.dither = InterleavedGradientNoise(input.positionCS.xy, 0);

    #if defined(_PREMULTIPLY_ALPHA)
    BRDF brdf = GetBRDF(surface, true);
    #else
    BRDF brdf = GetBRDF(surface);
    #endif

    GI gi = GetGI(GI_FRAGMENT_DATA(input), surface);
    float3 color = GetLighting(surface, brdf, gi);

    return half4(color, surface.alpha);
}

#endif
