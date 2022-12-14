Shader "Hidden/Special/Grass"
{
    Properties
    {
        [Header(Shading)]
        _TopColor("Top Color", Color) = (0,0.3764706,0.2588235,1)
        _BottomColor("Bottom Color", Color) = (0.1215686,0.9921568,0.01176471,1)
        _TranslucentGain("Translucent Gain", Range(0,1)) = 0.5
        [Space]
        _TessellationUniform ("Tessellation Uniform", Range(1, 64)) = 20
        [Header(Blades)]
        _BladeWidth("Blade Width", Float) = 0.05
        _BladeWidthRandom("Blade Width Random", Float) = 0.02
        _BladeHeight("Blade Height", Float) = 0.5
        _BladeHeightRandom("Blade Height Random", Float) = 0.3
        _BladeForward("Blade Forward Amount", Float) = 0.38
        _BladeCurve("Blade Curvature Amount", Range(1, 4)) = 2
        _BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2
        [Header(Wind)]
        _WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
        _WindStrength("Wind Strength", Range(0.1, 1)) = 0.5
        _WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
    }
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


    half4 _BottomColor;
    half4 _TopColor;
    float _BendRotationRandom;
    float _BladeHeight;
    float _BladeHeightRandom;
    float _BladeWidth;
    float _BladeWidthRandom;
    float _TessellationUniform;
    sampler2D _WindDistortionMap;
    float4 _WindDistortionMap_ST;
    float2 _WindFrequency;
    float _WindStrength;
    float _BladeForward;
    float _BladeCurve;
    float _TranslucentGain;
    #define BLADE_SEGMENTS 3
    #define UNITY_PI            3.14159265359f
    #define UNITY_TWO_PI        6.28318530718f

    struct geometryOutput
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 normal: NORMAL;
    };


    struct vertexInput
    {
        float4 vertex : POSITION;
        float3 normal: NORMAL;
        float4 tangent: TANGENT;
    };

    struct vertexOutput
    {
        float4 vertex : SV_POSITION;
        float3 normal: NORMAL;
        float4 tangent: TANGENT;
    };

    struct TessellationFactors
    {
        float edge[3] : SV_TessFactor;
        float inside : SV_InsideTessFactor;
    };


    float rand(float3 co)
    {
        return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
    }

    float3x3 AngleAxis3x3(float angle, float3 axis)
    {
        float c, s;
        sincos(angle, s, c);
        float t = 1 - c;
        float x = axis.x;
        float y = axis.y;
        float z = axis.z;

        return float3x3(
            t * x * x + c, t * x * y - s * z, t * x * z + s * y,
            t * x * y + s * z, t * x * y * y + c, t * y * z - s * x,
            t * x * z - s * y, t * y * z + s * x, t * z * z + c
        );
    }


    geometryOutput VertexOutput(float3 pos, float2 uv, float4 normal)
    {
        geometryOutput o;
        o.pos = TransformObjectToHClip(pos);
        o.uv = uv;
        o.normal = ComputeScreenPos(normal);
        return o;
    }


    geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv,
                                       float3x3 transformMatrix)
    {
        float3 tangentPoint = float3(width, forward, height);

        float3 tangentNormal = normalize(float3(0, -1, forward));

        float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
        float3 localNormal = mul(transformMatrix, tangentNormal);
        float4 normal = float4(localNormal.xyz, 1);
        return VertexOutput(localPosition, localNormal, normal);
    }


    [maxvertexcount(BLADE_SEGMENTS*2+1)]
    void geo(triangle vertexOutput IN[3], inout TriangleStream<geometryOutput> triStream)
    {
        float3 pos = IN[0].vertex;

        float3 vNormal = IN[0].normal;
        float4 vTangent = IN[0].tangent;
        float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;
        float3x3 tangentToLocal = float3x3(
            vTangent.x, vBinormal.x, vNormal.x,
            vTangent.y, vBinormal.y, vNormal.y,
            vTangent.z, vBinormal.z, vNormal.z
        );


        float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
        float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;

        float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;

        float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
        float3 wind = normalize(float3(windSample.x, windSample.y, 0)); //Wind Vector

        //Wind旋转矩阵
        float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);

        float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));


        float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * _BendRotationRandom * UNITY_PI * 0.5,
                                                   float3(-1, 0, 0));

        float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, facingRotationMatrix), bendRotationMatrix),
                                            windRotation);


        float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);

        float forward = rand(pos.yyz) * _BladeForward;

        for (int i = 0; i < BLADE_SEGMENTS; i++)
        {
            float t = i / (float)BLADE_SEGMENTS;
            float segmentHeight = height * t;
            float segmentWidth = width * (1 - t);
            float segmentForward = pow(t, _BladeCurve) * forward;
            float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;
            triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t),
                                                 transformMatrix));
            triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t),
                                                 transformMatrix));
        }

        triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformationMatrix));
    }


    vertexOutput tessVert(vertexInput v)
    {
        vertexOutput o;
        // Note that the vertex is NOT transformed to clip
        // space here; this is done in the grass geometry shader.
        o.vertex = v.vertex;
        o.normal = v.normal;
        o.tangent = v.tangent;
        return o;
    }

    TessellationFactors patchConstantFunction(InputPatch<vertexInput, 3> patch)
    {
        TessellationFactors f;
        f.edge[0] = _TessellationUniform;
        f.edge[1] = _TessellationUniform;
        f.edge[2] = _TessellationUniform;
        f.inside = _TessellationUniform;
        return f;
    }

    [domain("tri")]
    [outputcontrolpoints(3)]
    [outputtopology("triangle_cw")]
    [partitioning("integer")]
    [patchconstantfunc("patchConstantFunction")]
    vertexInput hull(InputPatch<vertexInput, 3> patch, uint id : SV_OutputControlPointID)
    {
        return patch[id];
    }

    [domain("tri")]
    vertexOutput domain(TessellationFactors factors, OutputPatch<vertexInput, 3> patch,
                        float3 barycentricCoordinates : SV_DomainLocation)
    {
        vertexInput v;

        #define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = \
		patch[0].fieldName * barycentricCoordinates.x + \
		patch[1].fieldName * barycentricCoordinates.y + \
		patch[2].fieldName * barycentricCoordinates.z;

        MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
        MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
        MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)

        return tessVert(v);
    }


    vertexOutput vert(vertexInput v)
    {
        vertexOutput o;
        o.vertex = v.vertex;
        o.normal = v.normal;
        o.tangent = v.tangent;
        return o;
    }

    half4 frag(geometryOutput i, half facing: VFACE) : SV_Target
    {
        float3 normal = facing > 0 ? i.normal : -i.normal;
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.pos);
        half shadow = MainLightRealtimeShadow(SHADOW_COORDS);
        float NdotL = saturate(saturate(dot(normal, _MainLightPosition)) + _TranslucentGain) * shadow;
        float3 ambient = SampleSH(float4(normal, 1));
        float4 lightIntensity = NdotL * _MainLightColor + float4(ambient, 1);
        float4 col = lerp(_BottomColor, _TopColor * lightIntensity, i.uv.y);

        return col;
    }
    ENDHLSL
    SubShader
    {
        Cull Off

        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "UniversalForward"

            }
            HLSLPROGRAM
            #pragma require geometry
            #pragma multi_compile_fwdbase
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geo
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}