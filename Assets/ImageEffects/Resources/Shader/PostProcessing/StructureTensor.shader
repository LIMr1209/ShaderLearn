Shader "Hidden/ImageEffects/Structure Tensor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    HLSLINCLUDE
    #include "../HLSL/Base.hlsl"
    #define PIXEL_X (_ScreenParams.z - 1)
    #define PIXEL_Y (_ScreenParams.w - 1)


    float3 SampleMain(float2 uv)
    {
        return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
    }

    float3 SobelU(float2 uv)
    {
        return (
            -1.0f * SampleMain(uv + float2(-PIXEL_X, -PIXEL_Y)) +
            -2.0f * SampleMain(uv + float2(-PIXEL_X, 0)) +
            -1.0f * SampleMain(uv + float2(-PIXEL_X, PIXEL_Y)) +

            1.0f * SampleMain(uv + float2(PIXEL_X, -PIXEL_Y)) +
            2.0f * SampleMain(uv + float2(PIXEL_X, 0)) +
            1.0f * SampleMain(uv + float2(PIXEL_X, PIXEL_Y))
        ) / 4.0;
    }

    float3 SobelV(float2 uv)
    {
        return (
            -1.0f * SampleMain(uv + float2(-PIXEL_X, -PIXEL_Y)) +
            -2.0f * SampleMain(uv + float2(0, -PIXEL_Y)) +
            -1.0f * SampleMain(uv + float2(PIXEL_X, -PIXEL_Y)) +

            1.0f * SampleMain(uv + float2(-PIXEL_X, PIXEL_Y)) +
            2.0f * SampleMain(uv + float2(0, PIXEL_Y)) +
            1.0f * SampleMain(uv + float2(PIXEL_X, PIXEL_Y))
        ) / 4.0;
    }

    float3 StructureTensor(float2 uv)
    {
        float3 u = SobelU(uv);
        float3 v = SobelV(uv);

        return float3(dot(u, u), dot(v, v), dot(u, v));
    }

    float3 SmoothedStructureTensor(float2 uv, float sigma)
    {
        float twiceSigmaSq = 2.0f * sigma * sigma;
        int halfWidth = ceil(2 * sigma);

        float3 col = float3(0, 0, 0);
        float norm = 0;
        for (int i = -halfWidth; i <= halfWidth; i++)
        {
            for (int j = -halfWidth; j <= halfWidth; j++)
            {
                float distance = sqrt(i * i + j * j);
                float k = exp(-distance * distance / twiceSigmaSq);

                col += StructureTensor(uv + float2(i * PIXEL_X, j * PIXEL_Y)) * k;
                norm += k;
            }
        }

        return col / norm;
    }

    half4 frag(VaryingsDefault input) : SV_Target
    {
        float3 t = SmoothedStructureTensor(input.texcoord, 2.0f);

        float lambda1 = 0.5f * (t.x + t.y + sqrt((t.x - t.y) * (t.x - t.y) + 4.0f * t.z * t.z));
        float lambda2 = 0.5f * (t.x + t.y - sqrt((t.x - t.y) * (t.x - t.y) + 4.0f * t.z * t.z));

        float2 direction = float2(lambda1 - t.x, -t.z);
        direction = (length(direction) > 0.0) ? normalize(direction) : float2(0, 1);

        float angle = atan2(direction.y, direction.x);

        float anisotropy = (lambda1 + lambda2 <= 0.0) ? 0.0 : (lambda1 - lambda2) / (lambda1 + lambda2);

        return half4(direction, angle, anisotropy);
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