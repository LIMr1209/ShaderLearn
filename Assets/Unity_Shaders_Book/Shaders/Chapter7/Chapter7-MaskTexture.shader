// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 遮罩纹理
Shader "Unity Shaders Book/Chapter 7/Mask Texture"
{
    Properties
    {
        _Color ("Color Tine", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "White" {}
        _BumpMap ("Normal Map", 2D) = "bump" {} // bump 是unity内置的法线纹理
        _BumpScale ("Bump Scale", Float) = 1.0 // 控制凹凸程度 为0 时 法线纹理 不会对光照产生影响
        _SpecularMask ("Specular Mask", 2D) = "white" {} // 高光反射遮罩纹理  
        _SpecularScale ("Specular Scale", Float) = 1.0 // 控制遮罩影响度得系数
        _Specular ("Specular", Color) = (1,1,1,1) // 高光反射颜色
        _Gloss ("Gloss", Range(8.0,256)) = 20 // 高光区域大小
    }
    SubShader
    {
        Pass
        {
            // pass 标签的一种 定义 光照流水线的角色
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 为了使用内置变量 需要 引入内置文件
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; // 纹理名_ST 固定名称 来声明纹理的属性 得到该纹理的 缩放和平移值 纹理名_ST.xy 缩放值 纹理名_ST.zw 是偏移值
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _SpecularMask;
            float4 _SpecularMask_ST;
            float _SpecularScale;

            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 tangent: TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                // 通常，如果我们需要把一些自定义的数据从顶点着色器传递给片元着色器，一般选用TEXCOORD0等。
                float2 uv: TEXCOORD0;
                float3 lightDir: TEXCOORD1;
                float3 viewDir: TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);

                fixed3 tangentViewDri = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv); // 采样

                fixed3 tangentNormal;

                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDri);

                // 每个 纹素得 rgb 值 一样 所以 遮罩纹理采样 r 分量计算掩码值  乘以  _SpecularScale 控制高光反射得强度
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) *
                    specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}