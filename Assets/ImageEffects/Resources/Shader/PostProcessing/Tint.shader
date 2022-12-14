Shader "Hidden/ImageEffects/Tint"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"

    half _Intensity;
	half4 _ColorTint;


    half4 Frag(VaryingsDefault i): SV_Target
	{	
		half4 sceneColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		
		half3 finalColor = lerp(sceneColor.rgb, sceneColor.rgb * _ColorTint.rgb, _Intensity);
		
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