// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 顶点动画 广告牌
Shader "Unity Shaders Book/Chapter 11/Billboard"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader
    {
        // DisableBatching 禁用壁橱里
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

            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _VerticalBillboarding;

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

                // 假设对象空间的中心是固定的  锚点
                float3 center = float3(0, 0, 0);
                // 获取模型空间下的相机位置
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                float3 normalDir = viewer - center; // 计算目标法线方向
                // _VerticalBillboarding 为 1 法线方向固定为视角方向
                // _VerticalBillboarding 为 9 则向上视角固定为 (0,1,0)
                normalDir.y = normalDir.y * _VerticalBillboarding; // 使用  _VerticalBillboarding 控制垂直方向上的约束度
                normalDir = normalize(normalDir);
                // 获取向上方向
                // 如果正常方向已经朝上，则向上方向朝前
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir)); // 叉积 向上方向和法线方向 得到向右方向
                upDir = normalize(cross(normalDir, rightDir));  // 叉积 法线方向和向右方向 得到向上方向

                float3 centerOffs = v.vertex.xyz - center; // 原始位置相对于锚点的偏移量
                // 新顶点位置
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

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