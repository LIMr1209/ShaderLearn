// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 切线空间 法线贴图
Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space"
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
                float3 lightDir : TEXCOORD1; // 切线空间下的 光照方向
                float3 viewDir : TEXCOORD2; // 切线空间下的 视角方向
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

                // // 计算副切线方向  w 分量 乘以 （法线和切线叉极）  和法线和切线方向都垂直的方向有两个 w 决定用哪个
                // float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                //
                //  // 模型空间下的切线方向 、 副切线方向 和法线方向 按行排列 得到 从模型空间到切线空间的变换矩阵
                // float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                // 直接使用内置宏
                TANGENT_SPACE_ROTATION; // 从模型空间到切线空间的变换矩阵

                // ObjSpaceLightDir 模型空间下的光照方向 然后使用 变换矩阵 rotation 把模型空间转换到切线空间 
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                // ObjSpaceViewDir 模型空间下的视角方向 然后使用 变换矩阵 rotation 把模型空间转换到切线空间 
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);

                fixed3 tangentViewDri = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv); // 采样

                fixed3 tangentNormal;

                // 如果贴图没有标记为法线
                // tangentNormal.xy = (packedNormal.xy *2 -1) * _BumpScale;
                // tangentNormal.z = sqrt(1.0-saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 如果贴图被标记为 法线 使用内置函数

                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDri);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);


                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}