Shader "MagicRP/Unlit"
{
    Properties
    {
        _BaseColor("_baseColor", Color) = (0.5, 0.5, 0.5, 1)
        _BaseMap("_BaseMap", 2D) = "white"{}
        _Cutoff ("Alpha Cutoff", Range(0.0, 1)) = 0.5
        [Toggle(_CLIPPING)]_Clipping("Alpha Clipping", Float) = 0
        [KeywordEnum(On, Clip, Dither, Off)] _Shadows("Shadows", Float) = 0
    }
    SubShader
    {
        HLSLINCLUDE
        #include "../ShaderLibrary/Common.hlsl"
        #include "UnlitInput.hlsl"
        ENDHLSL
        Pass
        {
            Cull Off
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment
            #pragma shader_feature _CLIPPING
            #pragma target 3.5


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

            Varyings UnlitPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                float3 positionWS = TransformObjectToWorld(input.positionOS);

                output.uv = TransformBaseUV(input.baseUV);
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }

            half4 UnlitPassFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);

                half4 base = GetBase(input.uv);
                #ifdef _CLIPPING
                clip(base.a - GetCutoff(input.uv));
                #endif

                return base;
            }
            ENDHLSL
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.5
            #pragma shader_feature _ _SHADOWS_CLIP _SHADOWS_DITHER
            #pragma multi_compile_instancing
            #include "ShadowCasterPass.hlsl"
            #pragma vertex ShadowCasterPassVertex
            #pragma fragment ShadowCasterPassFragment
            ENDHLSL
        }
    }
    CustomEditor "MagicRPShaderGUI"
}