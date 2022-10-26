// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 水波
Shader "Unity Shaders Book/Chapter 15/Water Wave"
{
    Properties
    {
        _Color ("Main Color", Color) = (0, 0.15, 0.115, 1) // 水面颜色
        _MainTex ("Base (RGB)", 2D) = "white" {} // 水面波纹材质纹理
        _WaveMap ("Wave Map", 2D) = "bump" {} // 噪声纹理生成的法线纹理
        _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {} // 模拟反射的环境纹理
        _WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01 // 控制法线纹理在X方向上的平移速度
        _WaveYSpeed ("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01 // 控制法线纹理在Y方向上的平移速度
        _Distortion ("Distortion", Range(0, 100)) = 10 // 模拟折射时图像的扭曲程度
    }
    SubShader
    {
        // 渲染通道 Transparent
        Tags
        {
            "Queue"="Transparent" "RenderType"="Opaque"
        }

        // 抓取屏幕图像 模拟折射
        GrabPass
        {
            "_RefractionTex"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _WaveMap;
            float4 _WaveMap_ST;
            samplerCUBE _Cubemap;
            fixed _WaveXSpeed;
            fixed _WaveYSpeed;
            float _Distortion;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
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
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

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
                float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed); //计算法线纹理的偏移量

                // 获取法线方向 切线空间  两次采样  模拟两层交叉水面波动
                fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
                fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
                fixed3 bump = normalize(bump1 + bump2);

                // 在切线空间下 计算偏移
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;

                // 采样折射颜色
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                // 法线方向 切线空间下 转到世界空间
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                
                fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb * _Color.rgb;

                // 菲捏耳
                fixed fresnel = pow(1 - saturate(dot(worldViewDir, bump)), 4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
    // Do not cast shadow
    FallBack Off
}