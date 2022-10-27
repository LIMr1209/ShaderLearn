// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 运动模糊
Shader "Unity Shaders Book/Chapter 13/Motion Blur With Depth Texture"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture; // unity 传递的深度纹理
        float4x4 _CurrentViewProjectionInverseMatrix; // 当前 视角*投影矩阵 逆矩阵
        float4x4 _PreviousViewProjectionMatrix;  // 上一帧 视角*投影矩阵
        half _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1; // 深度纹理采样的纹理坐标
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;


            // DirectX 需要处理平台差异导致的图像翻转
            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif

            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            // 获取此像素处的深度缓冲区值。  深度纹理采样获取深度值
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            // H是此像素处的视口位置，范围为-1到1。
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
            // 通过视角投影逆矩阵转进行变换。
            float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
            // 除以w得到世界位置。
            float4 worldPos = D / D.w;

            // 当前视口位置· 
            float4 currentPos = H;
            // 使用世界位置，并通过上一个视图投影矩阵进行变换。
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            //除以w转换为非齐次点[-1,1]。
            previousPos /= previousPos.w;

            // 使用此帧的位置和最后一帧的位置来计算像素速度。
            float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

            float2 uv = i.uv;
            // 原图像采样
            float4 c = tex2D(_MainTex, uv);

            // 对领域像素进行采样， 相加取平均数 得到模糊效果
            uv += velocity * _BlurSize;
            for (int it = 1; it < 3; it++, uv += velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex, uv);
                c += currentColor;
            }
            c /= 3;

            return fixed4(c.rgb, 1.0);
        }
        ENDCG

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack Off
}