﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 透明度测试的阴影投射
Shader "Unity Shaders Book/Chapter 9/Alpha Test With Shadow"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            // cull 指令 控制需要剔除哪个面的渲染图元  back 那些背对着摄像头的渲染图元不会被渲染 （默认）
            // front 朝向摄像机的渲染图元不会被渲染  off 关闭剔除
            Cull Off

            CGPROGRAM
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                // 将阴影坐标传递给像素着色器  计算声明的 阴影纹理坐标
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                clip(texColor.a - _Cutoff);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                // UNITY_LIGHT_ATTENUATION 不仅计算衰减，还计算阴影信息
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + diffuse * atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit" // 使用透明度测试的 阴影投射 注意 _Cutoff 属性名保持一致
}