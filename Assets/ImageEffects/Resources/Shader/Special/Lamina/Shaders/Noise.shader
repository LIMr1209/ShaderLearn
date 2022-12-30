Shader "Hidden/Special/Lamina/Noise"
{
    Properties
    {
        _ColorA("ColorA", Color) = (0.4,0.4,0.4,1)
        _ColorB("ColorB", Color) = (0.4,0.4,0.4,1)
        _ColorC("ColorC", Color) = (1,1,1,1)
        _ColorD("ColorD", Color) = (1,1,1,1)
        [ShowAsVector3] _Offset("Offset", Vector) = (0,0,0,0)
        _Alpha("Alpha (default = 1)", range(0,1)) = 1
        _Scale("Scale", Range(0, 100)) = 10


        [Enum(NoiseMappingEnum)]_Mapping("Mapping", Int) = 1
        [Enum(NoiseTypeEnum)]_Type("Type", Int) = 1

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Int) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Int) = 10 // 10 = OneMinusSrcAlpha
        [Enum(BlendModeEnum)]_BlendOp("_BlendOp (default = Add)", Int) = 0 // 0 = Add
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching" = "True" "IgnoreProjector" = "True"
        }

        Pass
        {
            BlendOp [_BlendOp]
            Blend[_SrcBlend][_DstBlend]
            Cull Back
            ZTest LEqual
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _UnityFogEnable

            #include "UnityCG.cginc"
            #include "NoiseHelp.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 position : TEXCOORD1;
            };

            half4 _ColorA;
            half4 _ColorB;
            half4 _ColorC;
            half4 _ColorD;
            half _Alpha;
            half3 _Offset;
            half _Scale;
            int _Mapping;
            int _Type;


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                if (_Mapping == 0)
                {
                    o.position = UnityObjectToClipPos(v.vertex);
                }
                else if (_Mapping == 1)
                {
                    o.position = mul(unity_ObjectToWorld, v.vertex);
                }
                else
                {
                    o.position = float3(v.uv, 0);
                }
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float f_n;
                if (_Type == 0)
                {
                    f_n = lamina_noise_white((i.position + _Offset) * _Scale);
                }
                else if (_Type == 1)
                {
                    f_n = lamina_noise_perlin((i.position + _Offset) * _Scale);
                }
                else
                {
                    f_n = lamina_noise_simplex((i.position + _Offset) * _Scale);
                }

                float f_step1 = 0.;
                float f_step2 = 0.2;
                float f_step3 = 0.6;
                float f_step4 = 1.;
                half3 f_color = lerp(_ColorA, _ColorB, smoothstep(f_step1, f_step2, f_n));
                f_color = lerp(f_color, _ColorC, smoothstep(f_step2, f_step3, f_n));
                f_color = lerp(f_color, _ColorD, smoothstep(f_step3, f_step4, f_n));

                return half4(f_color, _Alpha);
            }
            ENDCG
        }
    }
}