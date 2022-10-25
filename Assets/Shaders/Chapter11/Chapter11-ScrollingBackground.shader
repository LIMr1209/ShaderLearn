// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 滚动的背景
Shader "Unity Shaders Book/Chapter 11/Scrolling Background"
{
    Properties
    {
        _MainTex ("Base Layer (RGB)", 2D) = "white" {} // 较远的纹理
        _DetailTex ("2nd Layer (RGB)", 2D) = "white" {} // 较近的纹理
        _ScrollX ("Base layer Scroll Speed", Float) = 1.0 // 水平速度
        _Scroll2X ("2nd layer Scroll Speed", Float) = 1.0 // 水平速度
        _Multiplier ("Layer Multiplier", Float) = 1 // 控制纹理的整体亮度
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue"="Geometry"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _DetailTex;
            float4 _MainTex_ST;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // 裁剪空间的位置

                // frac 返回标量或每个矢量分量的小数部分
                // 水平方向偏移
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);

                // 使用第二层纹理的透明通道 混合两张纹理
                fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
                c.rgb *= _Multiplier;

                return c;
            }
            ENDCG
        }
    }
    FallBack "VertexLit"
}