Shader "Hidden/ImageEffects/Line Integral Convolution"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _NoiseTex ("Noise Texture", 2D) = "white" {}

        [IntRange] _StreamLineLength ("Stream Line Length", Range(1, 64)) = 10
        _KernelStrength ("Stream Kernel Strength", Range(0, 2)) = 0.5
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"
    #define SCREEN_WIDTH _ScreenParams.x
    #define SCREEN_HEIGHT _ScreenParams.y
    #define SCREEN_SIZE _ScreenParams.xy
    #define PIXEL_X (_ScreenParams.z - 1)
    #define PIXEL_Y (_ScreenParams.w - 1)

    #define MAX_LENGTH 64


    TEXTURE2D(_NoiseTex);
    SAMPLER(sampler_NoiseTex);
    float4 _NoiseTex_TexelSize;

    int _StreamLineLength;
    float _KernelStrength;

    float2 SampleMain(float2 uv)
    {
        return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rg;
    }

    float3 SampleNoise(float2 uv)
    {
        float x = uv.x * SCREEN_WIDTH / _NoiseTex_TexelSize.z;
        float y = uv.y * SCREEN_HEIGHT / _NoiseTex_TexelSize.w;
        return SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, float2(x, y)).rgb;
    }

    float2 GetVectorField(float2 uv)
    {
        float2 g = SampleMain(uv);

        float norm = length(g);

        return norm == 0 ? float2(0, 0) : g / norm;
    }

    float2 QuantizeToPixel(float2 uv)
    {
        return floor(uv * SCREEN_SIZE) / SCREEN_SIZE;
    }

    bool InBounds(float2 uv)
    {
        float2 clamped = saturate(uv);
        return clamped == uv;
    }

    float2 FilterKernel(float2 uv, float kernelStrength)
    {
        float2 v = GetVectorField(uv);
        float2 k1 = v * kernelStrength;

        v = GetVectorField(uv + 0.5f * k1);
        float2 k2 = v * kernelStrength;

        v = GetVectorField(uv + 0.5f * k2);
        float2 k3 = v * kernelStrength;

        v = GetVectorField(uv + k3);
        float2 k4 = v * kernelStrength;

        return uv + (k1 / 6.0f) + (k2 / 3.0f) + (k3 / 3.0f) + (k4 / 6.0f);
    }

    half4 frag(VaryingsDefault input) : SV_Target
    {
        // Compute stream line
        float2 forwardStream[MAX_LENGTH];
        float2 backwardStream[MAX_LENGTH];

        float2 forward = input.texcoord;
        float2 backward = input.texcoord;

        for (int i = 0; i < _StreamLineLength; i++)
        {
            float kernelStrength = _KernelStrength * PIXEL_X;

            forward = FilterKernel(forward, kernelStrength);
            forwardStream[i] = forward;

            backward = FilterKernel(backward, -kernelStrength);
            backwardStream[i] = backward;
        }

        for (int j = 0; j < _StreamLineLength; j++)
        {
            forwardStream[j] = QuantizeToPixel(forwardStream[j]);
            backwardStream[j] = QuantizeToPixel(backwardStream[j]);
        }

        // Integrate stream line
        float3 integral = float3(0, 0, 0);
        int k = 0;

        for (int n = 0; n < _StreamLineLength; n++)
        {
            float2 xi = forwardStream[n];
            if (InBounds(xi))
            {
                integral += SampleNoise(xi);
                k++;
            }

            xi = backwardStream[n];
            if (InBounds(xi))
            {
                integral += SampleNoise(xi);
                k++;
            }
        }
        integral /= k;

        return half4(integral, 0);
    }
    ENDHLSL
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment frag
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}