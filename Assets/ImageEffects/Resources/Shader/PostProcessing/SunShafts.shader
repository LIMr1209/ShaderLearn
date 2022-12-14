Shader "Hidden/ImageEffects/SunShafts"
{
    Properties
    {
        _MainTex ("Base", 2D) = "" {}
    }

    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 texcoord : TEXCOORD0;
        #if UNITY_UV_STARTS_AT_TOP
        float2 texcoord1 : TEXCOORD1;
        #endif
    };

    struct v2f_radial
    {
        float4 pos : SV_POSITION;
        float2 texcoord : TEXCOORD0;
        float2 blurVector : TEXCOORD1;
    };

    TEXTURE2D(_ColorBuffer);
    SAMPLER(sampler_ColorBuffer);
    TEXTURE2D(_Skybox);
    SAMPLER(sampler_Skybox);

    uniform half4 _SunThreshold;

    uniform half4 _SunColor;
    uniform half4 _BlurRadius4;
    uniform half4 _SunPosition;

    #define SAMPLES_FLOAT 6.0f
    #define SAMPLES_INT 6

    v2f vert(AttributesDefault v)
    {
        v2f o;
        o.vertex = TransformObjectToHClip(v.vertex);
        o.texcoord = v.texcoord.xy;

        #if UNITY_UV_STARTS_AT_TOP
        o.texcoord1 = v.texcoord.xy;
        if (_MainTex_TexelSize.y < 0)
            o.texcoord1.y = 1 - o.texcoord1.y;
        #endif

        return o;
    }

    half4 fragScreen(v2f i) : SV_Target
    {
        half4 colorA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);
        #if UNITY_UV_STARTS_AT_TOP
        half4 colorB = SAMPLE_TEXTURE2D(_ColorBuffer, sampler_ColorBuffer, i.texcoord1.xy);
        #else
		half4 colorB = SAMPLE_TEXTURE2D(_ColorBuffer, sampler_ColorBuffer, i.texcoord.xy);
        #endif
        half4 depthMask = saturate(colorB * _SunColor);
        return 1.0f - (1.0f - colorA) * (1.0f - depthMask);
    }

    half4 fragAdd(v2f i) : SV_Target
    {
        half4 colorA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);
        #if UNITY_UV_STARTS_AT_TOP
        half4 colorB = SAMPLE_TEXTURE2D(_ColorBuffer, sampler_ColorBuffer, i.texcoord1.xy);
        #else
		half4 colorB = SAMPLE_TEXTURE2D(_ColorBuffer, sampler_ColorBuffer, i.texcoord.xy);
        #endif
        half4 depthMask = saturate(colorB * _SunColor);
        return colorA + depthMask;
    }

    v2f_radial vert_radial(AttributesDefault v)
    {
        v2f_radial o;
        o.pos = TransformObjectToHClip(v.vertex);

        o.texcoord.xy = v.texcoord.xy;
        o.blurVector = (_SunPosition.xy - v.texcoord.xy) * _BlurRadius4.xy;

        return o;
    }

    half4 frag_radial(v2f_radial i) : SV_Target
    {
        half4 color = half4(0, 0, 0, 0);
        for (int j = 0; j < SAMPLES_INT; j++)
        {
            half4 tmpColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);
            color += tmpColor;
            i.texcoord.xy += i.blurVector;
        }
        return color / SAMPLES_FLOAT;
    }

    half TransformColor(half4 skyboxValue)
    {
        return dot(max(skyboxValue.rgb - _SunThreshold.rgb, half3(0, 0, 0)), half3(1, 1, 1));
        // threshold and convert to greyscale
    }

    half4 frag_depth(v2f i) : SV_Target
    {
        #if UNITY_UV_STARTS_AT_TOP
        float depthSample = SampleSceneDepth(i.texcoord1.xy);
        #else
		float depthSample = SampleSceneDepth(i.texcoord.xy);		
        #endif

        half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);


        // consider maximum radius
        #if UNITY_UV_STARTS_AT_TOP
        half2 vec = _SunPosition.xy - i.texcoord1.xy;
        #else
		half2 vec = _SunPosition.xy - i.uv.xy;		
        #endif
        half dist = saturate(_SunPosition.w - length(vec.xy));

        half4 outColor = 0;

        // consider shafts blockers
        if (depthSample > 0.99)
            outColor = TransformColor(tex) * dist;

        return outColor;
    }

    half4 frag_nodepth(v2f i) : SV_Target
    {
        #if UNITY_UV_STARTS_AT_TOP
        float4 sky = SAMPLE_TEXTURE2D(_Skybox, sampler_Skybox, i.texcoord1.xy);
        #else
		float4 sky = SAMPLE_TEXTURE2D(_Skybox, sampler_Skybox, i.texcoord.xy);
        #endif

        float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord.xy);

        // consider maximum radius
        #if UNITY_UV_STARTS_AT_TOP
        half2 vec = _SunPosition.xy - i.texcoord1.xy;
        #else
		half2 vec = _SunPosition.xy - i.texcoord.xy;		
        #endif
        half dist = saturate(_SunPosition.w - length(vec));

        half4 outColor = 0;

        // find unoccluded sky pixels
        // consider pixel values that differ significantly between framebuffer and sky-only buffer as occluded
        if (Luminance(abs(sky.rgb - tex.rgb)) < 0.2)
            outColor = TransformColor(sky) * dist;

        
        return outColor;
    }
    ENDHLSL

    Subshader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragScreen
            ENDHLSL
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert_radial
            #pragma fragment frag_radial
            ENDHLSL
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag_depth
            ENDHLSL
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag_nodepth
            ENDHLSL
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragAdd
            ENDHLSL
        }
    }

    Fallback off

}