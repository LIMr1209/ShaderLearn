Shader "Hidden/Special/Lamina/Texture"
{
    Properties
    {
        [MainTex]_MainTex ("Main Tex", 2D) = "white" {}
        _Alpha("Alpha (default = 1)", range(0,1)) = 1

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Int) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Int) = 10 // 10 = OneMinusSrcAlpha
        [Enum(BlendModeEnum)]_BlendOp("_BlendOp (default = Add)", Int) = 0 // 0 = Add
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching" = "True" "IgnoreProjector" = "True"
        }

        Pass
        {
            BlendOp [_BlendOp]
            Blend[_SrcBlend][_DstBlend]
            Cull Back
            ZTest LEqual
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            half _Alpha;
            sampler2D _MainTex;
            float4 _MainTex_ST;


            v2f vert(a2v v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                return half4(texColor.xyz, texColor.a * _Alpha);
            }
            ENDCG
        }
    }
}