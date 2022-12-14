Shader "Hidden/ImageEffects/ScreenWaterDrop"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"

    TEXTURE2D(_ScreenWaterDropTex);
    SAMPLER(sampler_ScreenWaterDropTex);
    float _CurTime;
    float _DropSpeed;
    float _SizeX;
    float _SizeY;
    float _Distortion;
    half _TimeX;

    half4 Frag(VaryingsDefault i) : COLOR
    {
        float2 uv = i.texcoord.xy;

        // // 解决平台差异的问题。校正方向，若和规定方向相反，则将速度反向并加1
        // #if UNITY_UV_STARTS_AT_TOP
        // if (_MainTex_TexelSize.y < 0)
        //     _DropSpeed = 1 - _DropSpeed;
        // #endif

        //设置三层水流效果，按照一定的规律在水滴纹理上分别进行取样

        float3 rainTex1 = SAMPLE_TEXTURE2D(_ScreenWaterDropTex, sampler_ScreenWaterDropTex, float2(uv.x * 1.15 * _SizeX,
                                               (uv.y * _SizeY * 1.1) + _CurTime * _DropSpeed * 0.15)).rgb / _Distortion;
        float3 rainTex2 = SAMPLE_TEXTURE2D(_ScreenWaterDropTex, sampler_ScreenWaterDropTex,
                                           float2(uv.x * 1.25 * _SizeX - 0.1,
                                               (uv.y * _SizeY * 1.2) + _CurTime * _DropSpeed * 0.2)).rgb / _Distortion;
        float3 rainTex3 = SAMPLE_TEXTURE2D(_ScreenWaterDropTex, sampler_ScreenWaterDropTex, float2(uv.x * _SizeX * 0.9,
                                               (uv.y * _SizeY * 1.25) + _CurTime * _DropSpeed * 0.032)).rgb / _Distortion;

        //整合三层水流效果的颜色信息，存于finalRainTex中
        float2 finalRainTex = uv.xy - (rainTex1.xy - rainTex2.xy - rainTex3.xy) / 3;

        //按照finalRainTex的坐标信息，在主纹理上进行采样
        float3 finalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(finalRainTex.x, finalRainTex.y)).rgb;

        //返回加上alpha分量的最终颜色值
        return half4(finalColor, 1.0);
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
            #pragma vertex VertDefault
            #pragma fragment Frag
            ENDHLSL

        }
    }
}