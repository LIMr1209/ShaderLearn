// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 世界空间 法线贴图
Shader "Unity Shaders Book/Chapter 7/Normal Map In World Space"
{
    Properties
    {
        _Color ("Color Tine", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "White" {}
        _BumpMap ("Normal Map", 2D) = "bump" {} // bump 是unity内置的法线纹理
        _BumpScale ("Bump Scale", Float) = 1.0 // 控制凹凸程度 为0 时 法线纹理 不会对光照产生影响
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
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 tangent : TANGENT; // 语义 表示 把 顶点的切线方向填充到 tangent 变量中  tangent.w  副切线的方向性
                float4 texcoord: TEXCOORD0; // 模型的第一组纹理坐标
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv: TEXCOORD0; // 存储纹理坐标 uv
                // 通常，如果我们需要把一些自定义的数据从顶点着色器传递给片元着色器，一般选用TEXCOORD0等。
                // 一个插值寄存器 最多只能存储 float4 的变量 对于矩阵  需要按行拆除 
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                // 实际上 通常会使用 同一组纹理坐标
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex); // xy 存储 主纹理的 纹理坐标
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap); // zw 存储 法线纹理的 纹理坐标

                // 世界空间下的顶点位置
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // 世界空间下的法线 切线 和副切线
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;


                // 切线空间到世界空间 的变换矩阵
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

                // 使用点乘操作 实现矩阵 每一行和法线相乘 实现 把法线从切线空间变换到世界空间下
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));


                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);


                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}