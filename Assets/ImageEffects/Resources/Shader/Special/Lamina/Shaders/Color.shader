Shader "Hidden/Special/Lamina/Color"
{
    Properties
    {
        [MainColor]_Color("_Color (default = 1,1,1,1)", Color) = (1,1,1,1)

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            half4 _Color;


            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}