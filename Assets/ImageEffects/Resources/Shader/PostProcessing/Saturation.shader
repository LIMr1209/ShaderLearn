Shader "Hidden/ImageEffects/Saturation"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"

    half _Saturation;

    half3 Saturation(half3 In, half Saturation)
    {
        half luma = dot(In, half3(0.2126729, 0.7151522, 0.0721750));
        half3 Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
        return Out;
    }

    half4 Frag(VaryingsDefault i) : SV_Target
    {
        half4 sceneColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

        return half4(Saturation(sceneColor.rgb, _Saturation), 1.0);
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