Shader "Hidden/Cyberpunk1"
{
    Properties
    {
        
        _MainTex("Base (RGB)", 2D) = "white" {}
        _Power("Power", Range(0,1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float _Power;
            CBUFFER_END

            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.rgb);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                float3 xyz = baseTex.rgb;
                float oldx = xyz.x;
                float oldy = xyz.y;
                float add = abs(oldx - oldy) * 0.5;
                float stepxy = step(xyz.y, xyz.x);
                float stepyx = 1 - stepxy;
                xyz.x = stepxy * (oldx + add) + stepyx * (oldx - add);
                xyz.y = stepyx * (oldy + add) + stepxy * (oldy - add);
                xyz.z = sqrt(xyz.z);
                baseTex.rgb = lerp(baseTex.rgb, xyz, _Power);
                return baseTex;
            }
            ENDHLSL
        }
    }
    Fallback off
}