// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 顶点动画 流动的河流
Shader "Unity Shaders Book/Chapter 11/Water"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Magnitude ("Distortion Magnitude", Float) = 1 // 水流波动的幅度
        _Frequency ("Distortion Frequency", Float) = 1 // 波动频率
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10 // 波长的倒数 越大 波长越小
        _Speed ("Speed", Float) = 0.5 // 移动速度
    }
    SubShader
    {
        // DisableBatching 取消批处理， 因为批处理会合并相关模型  模型空间就会丢失， 我们需要在模型空间下 对 顶点位置进行偏移
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;

                float4 offset;
                offset.yzw = float3(0.0, 0.0, 0.0);
                offset.x = sin(
                    _Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z *
                    _InvWaveLength) * _Magnitude;
                o.pos = UnityObjectToClipPos(v.vertex + offset);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv += float2(0.0, _Time.y * _Speed);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                c.rgb *= _Color.rgb;

                return c;
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}