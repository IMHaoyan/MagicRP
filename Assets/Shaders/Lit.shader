Shader "MagicRP/Lit"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white"{}
        _BaseColor("BaseColor", Color) = (0.5, 0.5, 0.5, 1)
        _Cutoff("Cutoff", Range(0, 1)) = 0.5
        [Toggle(_CLIPPING)]_Clipping("Alpha Clipping", Float) = 0
        [KeywordEnum(On, Clip, Dither, Off)] _Shadows("Shadows", Float) = 0

        _Metallic("Metallic", Range(0,1 )) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("Dst Blend", Float) = 10
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
        [Toggle(_PREMULTIPLY_ALPHA)] _PremulAlpha ("Premultiply Alpha", Float) = 1
        [Toggle(_RECEIVE_SHADOWS)]_ReceiveShadows("Receive Shadows", Float) = 1

    }
    SubShader
    {
		HLSLINCLUDE
		#include "../ShaderLibrary/Common.hlsl"
		#include "LitInput.hlsl"
		ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "MagicRPLit"
            }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            //Cull Off

            HLSLPROGRAM
            #pragma target 3.5
            #include "LitPass.hlsl"
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #pragma shader_feature _PREMULTIPLY_ALPHA
            #pragma multi_compile _ _DIRECTIONAL_PCF3 _DIRECTIONAL_PCF5 _DIRECTIONAL_PCF7
            #pragma multi_compile _ _CASCADE_BLEND_SOFT _CASCADE_BLEND_DITHER
            #pragma shader_feature _CLIPPING
            #pragma shader_feature _ _SHADOWS_CLIP _SHADOWS_DITHER
            #pragma shader_feature _RECEIVE_SHADOWS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_instancing
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
        /*
        Pass 
        {
        	Tags 
        	{
        	    "LightMode" = "Meta"
        	}
        	Cull Off
        
        	HLSLPROGRAM
        	#pragma target 3.5
        	#pragma vertex MetaPassVertex
        	#pragma fragment MetaPassFragment
        	#include "MetaPass.hlsl"
        	ENDHLSL
        }*/
    }
    CustomEditor "MagicRPShaderGUI"
}