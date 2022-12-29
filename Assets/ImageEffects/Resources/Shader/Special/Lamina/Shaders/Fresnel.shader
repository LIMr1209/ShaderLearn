Shader "Hidden/Special/Lamina/Fresnel"
{
    Properties
    {
        [MainColor]_Color("_Color (default = 1,1,1,1)", Color) = (1,1,1,1)
        _Bias("Bias", Range(0, 2)) = 0
        _Power("Power", Range(0, 3)) = 2
        _Intensity("Intensity", Range(0, 10)) = 1
        [Hidden]_Factor("Factor", float) = 1

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Int) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Int) = 10 // 10 = OneMinusSrcAlpha
        [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp (default = Add)", Int) = 1 // 1 = Add
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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            half4 _Color;
            half _Bias;
            half _Power;
            half _Intensity;
            half _Factor;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float f_a = ( _Factor + dot(i.worldPos, i.worldNormal));
                float f_fresnel = _Bias + _Intensity * pow(abs(f_a), _Power);
                f_fresnel = clamp(f_fresnel, 0.0, 1.0);
                return half4(f_fresnel * _Color);
            }
            ENDCG
        }
    }
}