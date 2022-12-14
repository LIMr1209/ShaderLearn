Shader "Hidden/ImageEffects/RadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurWidth("Blur Width", Range(0,1)) = 0.85
        _Intensity("Intesity", Range(0,1)) = 1
        _Center("Center", Vector) = (0.5,0.5,0,0)
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"

    #define NUM_SAMPLES 100

    float _BlurWidth;
    float _Intensity;
    float4 _Center;

    half4 frag(VaryingsDefault output) : SV_Target
    {
        half4 color = half4(0.0f, 0.0f, 0.0f, 1.0f);

        float2 ray = output.texcoord - _Center.xy;

        for (int i = 0; i < NUM_SAMPLES; i++)
        {
            float scale = 1.0f - _BlurWidth * (float(i) / float(NUM_SAMPLES - 1));
            color.xyz += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (ray * scale) + _Center.xy).rgb /
                float(NUM_SAMPLES);
        }

        return color * _Intensity;
    }
    ENDHLSL
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Cull Off ZWrite Off ZTest Always
        Blend One One
        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment frag
            ENDHLSL
        }
    }
    Fallback off
}