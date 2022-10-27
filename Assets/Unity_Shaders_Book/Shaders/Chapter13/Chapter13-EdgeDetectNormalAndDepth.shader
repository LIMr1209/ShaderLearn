// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 边缘检测
Shader "Unity Shaders Book/Chapter 13/Edge Detection Normals And Depth"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
        _SampleDistance ("Sample Distance", Float) = 1.0
        _Sensitivity ("Sensitivity", Vector) = (1, 1, 1, 1)  // x y 分量对应 深度 和法线的灵敏度
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        fixed _EdgeOnly;
        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;
        float _SampleDistance;
        half4 _Sensitivity;

        sampler2D _CameraDepthNormalsTexture; // 深度和法线纹理

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[5]: TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;
            o.uv[0] = uv;


            // 深度纹理采样坐标 平台差异化处理
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                uv.y = 1 - uv.y;
            #endif

            // Roberts 算子 需要采样的纹理坐标
            o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _SampleDistance;
            o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _SampleDistance;
            o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDistance;
            o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _SampleDistance;

            return o;
        }

        // 返回 1或者 0 ，0 表示 两点存在一条边界，反之则是 1
        half CheckSame(half4 center, half4 sample)
        {
            // float depth;
            // float3 normal;
            // DecodeDepthNormal(center, depth, normal); 解码深度法线
            half2 centerNormal = center.xy; // 获取法线
            // 解码法线  DecodeViewNormalStereo(center);
            float centerDepth = DecodeFloatRG(center.zw); // 获取解码深度值
            half2 sampleNormal = sample.xy;              
            float sampleDepth = DecodeFloatRG(sample.zw);

            // 法线差异
            //不要费心解码法线-这里没有必要
            half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
            int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1; // 和阈值比较
            // 深度差异
            float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
            // 按距离缩放所需阈值
            int isSameDepth = diffDepth < 0.1 * centerDepth;

            return isSameNormal * isSameDepth ? 1.0 : 0.0;
        }

        fixed4 fragRobertsCrossDepthAndNormal(v2f i) : SV_Target
        {
            half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
            half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
            half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
            half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

            half edge = 1.0;

            edge *= CheckSame(sample1, sample2);
            edge *= CheckSame(sample3, sample4);

            fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
            fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

            return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
        }
        ENDCG

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRobertsCrossDepthAndNormal
            ENDCG
        }
    }
    FallBack Off
}