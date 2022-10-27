// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 逐顶点光照 高光反射
Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1) // 漫反射颜色
        _Specular ("Specular", Color) = (1,1,1,1) // 高光反射颜色
        _Gloss ("Gloss", Range(8.0,256)) = 20 // 高光区域大小
    }
    SubShader
    {
        pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color: COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));


                // 计算入射光线方向关于表面法线的反射方向 reflectDir  reflect 函数要求入射方向 是由光源指向交点处 需要取反
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

                //  _WorldSpaceCameraPos 世界空间摄像头位置
                // 顶点位置 从模型空间转向 世界空间
                // 相减 得到世界空间下的视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}