#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


float4 _MainTex_ST;
float4 _MainTex_TexelSize;
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

struct AttributesDefault
{
    float3 vertex : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct VaryingsDefault
{
    float4 vertex : SV_POSITION;
    float2 texcoord : TEXCOORD0;
    // float2 texcoordStereo : TEXCOORD1;
};


VaryingsDefault VertDefault(AttributesDefault v)
{
    VaryingsDefault o;
    o.vertex = TransformObjectToHClip(v.vertex.rgb);
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
    return o;
}
