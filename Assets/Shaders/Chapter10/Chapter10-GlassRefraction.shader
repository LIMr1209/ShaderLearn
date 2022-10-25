// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// GrabPass 
Shader "Unity Shaders Book/Chapter 10/Glass Refraction"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {} // 主纹理
        _BumpMap ("Normal Map", 2D) = "bump" {} // 法线纹理
        _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {} // 环境纹理
        _Distortion ("Distortion", Range(0, 100)) = 10 // 控制模拟折射时图像的扭曲程度
        _RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0 // 控制折射程度  0 只包含反射 1 只包含折射
    }
    SubShader
    {
        // 使用Transparent 保证渲染该物体时 所有的不透明物体 已经绘制
        Tags
        {
            "Queue"="Transparent" "RenderType"="Opaque"
        }

        // 此过程将对象后面的屏幕捕捉为纹理。
        // 我们可以在下一个过程中以_RefractionTex的形式访问结果
        GrabPass
        {
            "_RefractionTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _Cubemap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex; // grabpass 纹理名称
            float4 _RefractionTex_TexelSize; // 该纹理的纹素大小   256x512  --> （1/256, 1/512）

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; // 语义 表示 把 顶点的切线方向填充到 tangent 变量中  tangent.w  副切线的方向性
                float2 texcoord: TEXCOORD0; // 模型的第一组纹理坐标
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.scrPos = ComputeGrabScreenPos(o.pos);  // 获取抓取的屏幕图像的采样坐标

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

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

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                // 获取法线方向 切线空间
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                // 在切线空间下 计算偏移
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;

                // 采样折射颜色
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                // 法线方向 切线空间下 转到世界空间
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                // 反射
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

                fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}