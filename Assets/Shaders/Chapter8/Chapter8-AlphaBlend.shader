// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 透明度混合
Shader "Unity Shaders Book/Chapter 8/Alpha Blend"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1 // 透明纹理得基础上 控制整体得透明度
    }
    SubShader
    {
        // Queue 指定渲染器队列 Transparent 透明度混合
        // RenderType 把这个shader 归入提前定义得组 中 指明 该shader 使用了 透明度测试  着色器替换功能
        // IgnoreProjector 设置 不会收到 投影器得影响	
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            ZWrite Off // 关闭深度写入
            // SrcAlpha 为原颜色（该片元着色器产生得颜色）的混合因子
            // OneMinusSrcAlpha 为 目标颜色（已经存在于颜色缓冲中的颜色）的混合因子
            Blend SrcAlpha OneMinusSrcAlpha // 开启混合 并设置 混合因子   


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

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
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));


                // 设置 返回值 中的透明通道 只有 使用 blend 命令开启混合才有效果
                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}