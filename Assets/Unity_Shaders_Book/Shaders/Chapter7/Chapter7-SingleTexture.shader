// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 纹理采样
Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
    Properties
    {
        _Color ("Color Tine", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "White" {}
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
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; // 纹理名_ST 固定名称 来声明纹理的属性 得到该纹理的 缩放和平移值 纹理名_ST.xy 缩放值 纹理名_ST.zw 是偏移值
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0; // 模型的第一组纹理坐标
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float2 uv: TEXCOORD2; // 存储纹理坐标 uv
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // 使用内置宏
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                // fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb; // 纹理采样 * color 作为材质 反射

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; //  环境光照乘以 albedo 得到反射光


                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                fixed3 halfDir = normalize(worldLightDir + viewDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}