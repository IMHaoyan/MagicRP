#ifndef MAGICRP_LIT_PASS_INCLUDED
#define MAGICRP_LIT_PASS_INCLUDED

// #include "../ShaderLibrary/Surface.hlsl"
// #include "../ShaderLibrary/Light.hlsl"
// #include "../ShaderLibrary/BRDF.hlsl"
// #include "../ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float2 baseUV : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings ShadowCasterPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    float3 positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(positionWS);

    #if UNITY_REVERSED_Z
    output.positionCS.z =
        min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
    output.positionCS.z =
        max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    output.uv = TransformBaseUV(input.baseUV);
    return output;
}

void ShadowCasterPassFragment(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    half4 base = GetBase(input.uv);

    #if defined(_SHADOWS_CLIP)
    clip(base.a -  GetCutoff(input.uv));
    #elif defined(_SHADOWS_DITHER)
    float dither = InterleavedGradientNoise(input.positionCS.xy, 0);
    clip(base.a - dither);
    #endif
}

#endif
