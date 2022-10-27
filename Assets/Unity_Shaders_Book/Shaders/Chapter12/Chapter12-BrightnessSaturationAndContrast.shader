// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 调整屏幕 亮度 饱和度 和对比度
Shader "Unity Shaders Book/Chapter 12/Brightness Saturation And Contrast"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        
        // 可以省略声明， 这儿声明的只会在材质面板中显示 ，对于后处理 不需要在面板上调整参数
        _Brightness ("Brightness", Float) = 1
        _Saturation("Saturation", Float) = 1
        _Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        Pass
        {
            // 关闭深度写入  如果当前的 OnRenderImage 函数在所有不透明的pass 执行完毕后调用，不关闭会影响后面 透明pass 的渲染
            // 后处理 标志标配
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv: TEXCOORD0;
            };

            v2f vert(appdata_img v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex, i.uv);

                // 应用亮度
                fixed3 finalColor = renderTex.rgb * _Brightness;

                // 应用饱和度
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b; // 饱和度和0的颜色值
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                // 应用对比度 
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5); // 对比度为0 的颜色值
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }

    Fallback Off
}