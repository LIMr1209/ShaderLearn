Shader "Hidden/Special/Lamina/Normal"
{
    Properties
    {
        _Alpha("Alpha (default = 1)", range(0,1)) = 1
        _Direction("Direction", Vector) = (1, 1, 1)

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Int) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Int) = 10 // 10 = OneMinusSrcAlpha
        [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp (default = Add)", Int) = 0 // 0 = Add
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: TEXCOORD1;
            };

            half _Alpha;
            half3 _Direction;


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {

                half3 f_normalColor;
                f_normalColor.x = i.normal.x * _Direction.x;
                f_normalColor.y = i.normal.y * _Direction.y;
                f_normalColor.z = i.normal.z * _Direction.z;

                return half4(f_normalColor, _Alpha);
            }
            ENDCG
        }
    }
}