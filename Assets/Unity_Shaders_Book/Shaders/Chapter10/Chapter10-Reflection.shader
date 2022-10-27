// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 反射
Shader "Unity Shaders Book/Chapter 10/Reflection"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _ReflectColor ("Reflection Color", Color) = (1, 1, 1, 1) // 反射颜色
        _ReflectAmount ("Reflect Amount", Range(0, 1)) = 1 // 反射程度
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {} // 反射贴图 cube 默认 unity 自带 _Skybox
    }
    SubShader
    {
        Tags
        {
            // 渲染队列几何体
            "RenderType"="Opaque" "Queue"="Geometry"
        }

        Pass
        {
            
            // 前向路径
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                // 计算反射方向
                // 物体反射到摄像机的光线方向 可以通过光路可逆的原则来方向求得
                // 计算视角方向关于顶点法线的反射方向来 求 入射光线的方向
                // 使用的入射光方向向量，是从外指向几何顶点的；平时我们在着色程序中或者在课本上都是将入射光方向向量作为从顶点出发
                // o.worldRefl = reflect(-normalize(o.worldViewDir), normalize(o.worldNormal));
                 o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

                // 使用世界空间中的反射方向来采样立方体映射
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                // 插值漫反射颜色和反射颜色
                fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}