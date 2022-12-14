Shader "Hidden/ImageEffects/Sharpen"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"

    half _CentralFactor;
    half _SideFactor;

    struct VertexOutput
	{
		float4 vertex: SV_POSITION;
		float2 texcoord: TEXCOORD0;
		float4 texcoord1  : TEXCOORD1;
	};

	VertexOutput Vert(AttributesDefault v)
	{
		VertexOutput o;
	    o.vertex = TransformObjectToHClip(v.vertex);
	    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.texcoord1 = half4(o.texcoord.xy - _MainTex_TexelSize.xy, o.texcoord.xy + _MainTex_TexelSize.xy);
		return o;
	}

	half4 Frag(VertexOutput i): SV_Target
	{
		half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy) * _CentralFactor;
		color -= SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord1.xy) * _SideFactor;
		color -= SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord1.xw) * _SideFactor;
		color -= SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord1.zy) * _SideFactor;
		color -= SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord1.zw) * _SideFactor;
		return color;
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