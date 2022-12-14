Shader "Hidden/ImageEffects/FogWithNoise"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

    TEXTURE2D(_NoiseTex);
    SAMPLER(sampler_NoiseTex);
    float4x4 _FrustumCornersRay;
    half _FogDensity;
    half4 _FogColor;
    float _FogStart;
    float _FogEnd;
    half _FogXSpeed;
    half _FogYSpeed;
    half _NoiseAmount;


    struct Attributes
    {
        float3 vertex : POSITION;
        float2 texcoord : TEXCOORD0;
    };

    struct Varyings
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float2 uv_depth : TEXCOORD1;
        float4 interpolatedRay: TEXCOORD2;
    };


    Varyings Vert(AttributesDefault v)
    {
        Varyings o;
        o.pos = TransformObjectToHClip(v.vertex.rgb);

        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

        o.uv_depth = o.uv;

        #if UNITY_UV_STARTS_AT_TOP
        if (_MainTex_TexelSize.y < 0)
            o.uv_depth.y = 1 - o.uv_depth.y;
        #endif

        int index = 0;
        if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
        {
            index = 0;
        }
        else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
        {
            index = 1;
        }
        else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
        {
            index = 2;
        }
        else
        {
            index = 3;
        }
        #if UNITY_UV_STARTS_AT_TOP
        if (_MainTex_TexelSize.y < 0)
            index = 3 - index;
        #endif

        o.interpolatedRay = _FrustumCornersRay[index];
        return o;
    }

    half4 Frag(Varyings i) : SV_Target
    {
        float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv_depth);
        float linearDepth = LinearEyeDepth(depth, _ZBufferParams);
        float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

        // 计算噪声纹理的偏移量
        float2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);

        float noise = (SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, i.uv + speed).r - 0.5) * _NoiseAmount;

        float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
        fogDensity = saturate(fogDensity * _FogDensity * (1 + noise));

        half4 finalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,i.uv);
        finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

        return finalColor;
    }
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL

        }
    }
}