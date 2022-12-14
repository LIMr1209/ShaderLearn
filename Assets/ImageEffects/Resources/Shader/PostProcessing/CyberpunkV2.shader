Shader "Hidden/ImageEffects/CyberpunkV2"
{
    Properties
    {
        
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Red("洋红-红色-橙色", Range(-1, 0.5)) = 0
        _Orange("红色-橙色-黄色", Range(-0.5, 0.5)) = 0
        _Yellow("橙色-黄色-绿色", Range(-0.5, 1)) = 0
        _Green("黄色-绿色-靛色", Range(-1, 1)) = 0
        _Cyan("绿色-靛色-蓝色", Range(-1, 1)) = 0
        _Blue("靛色-蓝色-紫色", Range(-1, 0.5)) = 0
        _Purple("蓝色-紫色-洋红", Range(-0.5, 0.5)) = 0
        _Magenta("紫色-洋红-红色", Range(-0.5, 1)) = 0

        _Power("饱和度调整", Range(1, 10)) = 1
        _Value("色调", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define ISIX 0.1666667
            //确定下原先各参考色相值
            #define  red 0
            #define orange 0.0833333
            #define yellow 0.1666667
            #define green 0.3333333
            #define cyan 0.5
            #define blue 0.66666667
            #define purple 0.75
            #define magenta 0.8333333

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };

            // struct v2f
            // {
            //     float2 uv : TEXCOORD0;
            //     float4 vertex : SV_POSITION;
            // };

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float _Red;
            float _Orange;
            float _Yellow;
            float _Green;
            float _Cyan;
            float _Blue;
            float _Purple;
            float _Magenta;

            float _Power;
            float _Value;
            CBUFFER_END


             /* 从UnityStandardParticles.cginc里翻出来的，虽然是转HSV的，但是现阶段并不用L/V所以就无所谓了 */
            float3 RGBtoHSV(float3 arg1)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 P = lerp(float4(arg1.bg, K.wz), float4(arg1.gb, K.xy), step(arg1.b, arg1.g));
                float4 Q = lerp(float4(P.xyw, arg1.r), float4(arg1.r, P.yzx), step(P.x, arg1.r));
                float D = Q.x - min(Q.w, Q.y);
                float E = 1e-10;
                return float3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
            }

            float3 HSVtoRGB(float3 arg1)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 P = abs(frac(arg1.xxx + K.xyz) * 6.0 - K.www);
                return arg1.z * lerp(K.xxx, saturate(P - K.xxx), arg1.y);
            }

            float cycle(float value)
            {
                if (value > 1)
                    return value - 1;
                if (value < 0)
                    return 1 + value;
                return value;
            }

            float Change(float s0, float e0, float s1, float e1, float value)
            {
                return (value - s0) / (e0 - s0) * (e1 - s1) + s1;
            }

            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.rgb);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                float3 hsl = RGBtoHSV(col.rgb);
                float h = hsl.x;
                float newRed = red + _Red * ISIX;
                float newOrange = orange + _Orange * ISIX;
                float newYellow = yellow + _Yellow * ISIX;
                float newGreen = green + _Green * ISIX;
                float newCyan = cyan + _Cyan * ISIX;
                float newBlue = blue + _Blue * ISIX;
                float newPurple = purple + _Purple * ISIX;
                float newMagenta = magenta + _Magenta * ISIX;
                //计算参考系变化后的色相值
                if (h > magenta) { h = Change(magenta, 1, newMagenta, 1 + newRed, h); }
                else if (h > purple) { h = Change(purple, magenta, newPurple, newMagenta, h); }
                else if (h > blue) { h = Change(blue, purple, newBlue, newPurple, h); }
                else if (h > cyan) { h = Change(cyan, blue, newCyan, newBlue, h); }
                else if (h > green) { h = Change(green, cyan, newGreen, newCyan, h); }
                else if (h > yellow) { h = Change(yellow, green, newYellow, newGreen, h); }
                else if (h > orange) { h = Change(orange, yellow, newOrange, newYellow, h); }
                else { h = Change(red, orange, newRed, newOrange, h); }
                hsl.x = cycle(h);
                hsl.y = 1 - pow(abs(1 - hsl.y), _Power);
                hsl.z = pow(abs(hsl.z), _Value);
                col.rgb = HSVtoRGB(hsl);
                return col;
                
            }
            ENDHLSL
        }
    }
    Fallback off
}



           


