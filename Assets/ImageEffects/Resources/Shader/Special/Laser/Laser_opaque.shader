Shader "Hidden/Special/LaserOpaque"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        _BaseColor("BaseColor", Color) = (1,1,1,0)
        _RefractHueScaleOffset("RefractHueScaleOffset", Vector) = (1,0,0,0)
        _RefractPresent("RefractPresent", Range( 0 , 1)) = 0.5
        _RefractIndrectFactor("RefractIndrectFactor", Range( 0 , 1)) = 0.5
        _ReflectHueScaleOffset("ReflectHueScaleOffset", Vector) = (1,0.5,0,0)
        _ReflectAlpha("ReflectAlpha", Range( 0 , 1)) = 1.0
        _ReflectIndirect("ReflectIndirect", Range( 0 , 1)) = 0.2
        _Specular("Specular", Range( 0 , 2)) = 1
        _SpecularPower("SpecularPower", Range( 0.1 , 50)) = 10
        [KeywordEnum(HueRamp,CubeMapDefault,CubeMapChaos)] _ReflectHue("ReflectHue", Float) = 0
        _CubeMap("CubeMap", CUBE) = "white" {}

    }

    SubShader
    {
        LOD 0
        Tags
        {
            "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"
        }

        Cull Back
        AlphaToMask Off

        HLSLINCLUDE
        #pragma target 3.0

        #pragma prefer_hlslcc gles
        #pragma exclude_renderers d3d11_9x

        #ifndef ASE_TESS_FUNCS
        #define ASE_TESS_FUNCS

        float4 FixedTess(float tessValue)
        {
            return tessValue;
        }

        float CalcDistanceTessFactor(float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w,
                                     float3 cameraPos)
        {
            float3 wpos = mul(o2w, vertex).xyz;
            float dist = distance(wpos, cameraPos);
            float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
            return f;
        }

        float4 CalcTriEdgeTessFactors(float3 triVertexFactors)
        {
            float4 tess;
            tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
            tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
            tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
            tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
            return tess;
        }

        float CalcEdgeTessFactor(float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams)
        {
            float dist = distance(0.5 * (wpos0 + wpos1), cameraPos);
            float len = distance(wpos0, wpos1);
            float f = max(len * scParams.y / (edgeLen * dist), 1.0);
            return f;
        }

        float DistanceFromPlane(float3 pos, float4 plane)
        {
            float d = dot(float4(pos, 1.0f), plane);
            return d;
        }

        bool WorldViewFrustumCull(float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6])
        {
            float4 planeTest;
            planeTest.x = ((DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f);
            planeTest.y = ((DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f);
            planeTest.z = ((DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f);
            planeTest.w = ((DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f) +
                ((DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f);
            return !all(planeTest);
        }

        float4 DistanceBasedTess(float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist,
                                 float4x4 o2w, float3 cameraPos)
        {
            float3 f;
            f.x = CalcDistanceTessFactor(v0, minDist, maxDist, tess, o2w, cameraPos);
            f.y = CalcDistanceTessFactor(v1, minDist, maxDist, tess, o2w, cameraPos);
            f.z = CalcDistanceTessFactor(v2, minDist, maxDist, tess, o2w, cameraPos);

            return CalcTriEdgeTessFactors(f);
        }

        float4 EdgeLengthBasedTess(float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos,
                                   float4 scParams)
        {
            float3 pos0 = mul(o2w, v0).xyz;
            float3 pos1 = mul(o2w, v1).xyz;
            float3 pos2 = mul(o2w, v2).xyz;
            float4 tess;
            tess.x = CalcEdgeTessFactor(pos1, pos2, edgeLength, cameraPos, scParams);
            tess.y = CalcEdgeTessFactor(pos2, pos0, edgeLength, cameraPos, scParams);
            tess.z = CalcEdgeTessFactor(pos0, pos1, edgeLength, cameraPos, scParams);
            tess.w = (tess.x + tess.y + tess.z) / 3.0f;
            return tess;
        }

        float4 EdgeLengthBasedTessCull(float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement,
                                       float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6])
        {
            float3 pos0 = mul(o2w, v0).xyz;
            float3 pos1 = mul(o2w, v1).xyz;
            float3 pos2 = mul(o2w, v2).xyz;
            float4 tess;

            if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
            {
                tess = 0.0f;
            }
            else
            {
                tess.x = CalcEdgeTessFactor(pos1, pos2, edgeLength, cameraPos, scParams);
                tess.y = CalcEdgeTessFactor(pos2, pos0, edgeLength, cameraPos, scParams);
                tess.z = CalcEdgeTessFactor(pos0, pos1, edgeLength, cameraPos, scParams);
                tess.w = (tess.x + tess.y + tess.z) / 3.0f;
            }
            return tess;
        }
        #endif //ASE_TESS_FUNCS
        ENDHLSL


        Pass
        {

            Name "Forward"
            Tags
            {
                "LightMode"="UniversalForwardOnly"
            }

            Blend One Zero, One Zero
            ZWrite On
            ZTest LEqual
            Offset 0 , 0
            ColorMask RGBA


            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1
            #define ASE_ABSOLUTE_VERTEX_POS 1
            #define ASE_SRP_VERSION 999999


            // #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma shader_feature _ _SAMPLE_GI
            // #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            // #pragma multi_compile _ DEBUG_DISPLAY
            #define SHADERPASS SHADERPASS_UNLIT


            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


            #define ASE_NEEDS_VERT_NORMAL
            #define ASE_NEEDS_FRAG_WORLD_POSITION
            #define ASE_NEEDS_FRAG_SHADOWCOORDS
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma shader_feature_local _REFLECTHUE_HUERAMP _REFLECTHUE_CUBEMAPDEFAULT _REFLECTHUE_CUBEMAPCHAOS


            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                float3 worldPos : TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
                #endif
                #ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
                #endif
                float4 lightmapUVOrVertexSH : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _RefractHueScaleOffset;
            float4 _ReflectHueScaleOffset;
            float4 _BaseColor;
            float _RefractPresent;
            float _RefractIndrectFactor;
            float _ReflectIndirect;
            float _Specular;
            float _SpecularPower;
            float _ReflectAlpha;
            #ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
            #endif
            CBUFFER_END
            samplerCUBE _CubeMap;


            float3 ASEIndirectDiffuse(float2 uvStaticLightmap, float3 normalWS)
            {
                #ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
                #else
                return SampleSH(normalWS);
                #endif
            }

            float3 HSVToRGB(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }


            VertexOutput VertexFunction(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(ase_worldNormal, o.lightmapUVOrVertexSH.xyz);
                o.ase_texcoord4.xyz = ase_worldNormal;


                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord4.w = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                float3 defaultVertexValue = v.vertex.xyz;
                #else
					float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                v.vertex.xyz = vertexValue;
                #else
					v.vertex.xyz += vertexValue;
                #endif
                v.ase_normal = v.ase_normal;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);

                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                o.worldPos = positionWS;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
                #endif
                #ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
                #endif
                o.clipPos = positionCS;
                return o;
            }

            #if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
            #if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
            #elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
            #elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
            #elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
            #endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
            #if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
            #endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
            #else
            VertexOutput vert(VertexInput v)
            {
                return VertexFunction(v);
            }
            #endif

            half4 frag(VertexOutput IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);

                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
                #endif
                #endif
                float3 ase_worldNormal = IN.ase_texcoord4.xyz;
                float3 bakedGI53 = ASEIndirectDiffuse(IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
                Light ase_mainLight = GetMainLight(ShadowCoords);
                MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI53, half4(0, 0, 0, 0));
                float3 ase_worldViewDir = (_WorldSpaceCameraPos.xyz - WorldPosition);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float dotResult23 = dot(ase_worldNormal, ase_worldViewDir);
                float3 hsvTorgb26 = HSVToRGB(float3((dotResult23 * _ReflectHueScaleOffset.x + _ReflectHueScaleOffset.y),
                                                    1.0, 1.0));
                float4 color27 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(1, 1, 1, 0);
                float3 appendResult29 = (float3(color27.rgb));
                float3 appendResult130 = (float3(texCUBE(_CubeMap, ase_worldNormal).rgb));
                float3 in_normal108 = ase_worldNormal;
                float3 break110 = in_normal108;
                float3 appendResult109 = (float3(-break110.x, break110.y, break110.z));
                float3 break120 = in_normal108;
                float3 appendResult113 = (float3(break120.x, -break120.y, break120.z));
                float3 break121 = in_normal108;
                float3 appendResult114 = (float3(-break121.x, -break121.y, break121.z));
                float4 appendResult123 = (float4(texCUBE(_CubeMap, appendResult109).r,
                                                 texCUBE(_CubeMap, appendResult113).g,
                                                 texCUBE(_CubeMap, appendResult114).b, 0.0));
                float3 appendResult126 = (float3(appendResult123.xyz));
                #if defined(_REFLECTHUE_HUERAMP)
                float3 staticSwitch125 = (hsvTorgb26 * appendResult29);
                #elif defined(_REFLECTHUE_CUBEMAPDEFAULT)
				float3 staticSwitch125 = appendResult130;
                #elif defined(_REFLECTHUE_CUBEMAPCHAOS)
				float3 staticSwitch125 = appendResult126;
                #else
				float3 staticSwitch125 = ( hsvTorgb26 * appendResult29 );
                #endif
                float3 ReflectColor58 = staticSwitch125;
                float dotResult41 = dot(_MainLightPosition.xyz, ase_worldNormal);
                float3 bakedGI91 = ASEIndirectDiffuse(IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
                MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI91, half4(0, 0, 0, 0));
                float RefractIndrectFactor88 = _RefractIndrectFactor;
                float temp_output_2_0_g22 = RefractIndrectFactor88;
                float temp_output_3_0_g22 = (1.0 - temp_output_2_0_g22);
                float3 appendResult7_g22 = (float3(temp_output_3_0_g22, temp_output_3_0_g22, temp_output_3_0_g22));
                float dotResult86 = dot(ase_worldNormal, ase_worldViewDir);
                float4 RefractHueScaleOffset82 = _RefractHueScaleOffset;
                float4 break87 = RefractHueScaleOffset82;
                float3 hsvTorgb94 = HSVToRGB(float3((dotResult86 * break87.x + break87.y), 1.0, 1.0));
                float RefractPresent93 = _RefractPresent;
                float3 lerpResult104 = lerp(float3(0, 0, 0),
                                            (((bakedGI91 * temp_output_2_0_g22) + appendResult7_g22) * hsvTorgb94),
                                            RefractPresent93);
                float3 appendResult132 = (float3(_BaseColor.rgb));
                float3 RefractColor101 = (lerpResult104 * appendResult132);

                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = ((((_ReflectIndirect * bakedGI53 * ReflectColor58) + (ReflectColor58 * _MainLightColor.
                        rgb * saturate(pow(abs((dotResult41 * 0.5 + 0.5) * _Specular), _SpecularPower)))) * _ReflectAlpha)
                    +
                    RefractColor101);
                float Alpha = 1;
                float AlphaClipThreshold = 0.5;
                float AlphaClipThresholdShadow = 0.5;

                #ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
                #endif

                #if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
                #endif

                #if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
                #endif


                #ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
                #endif

                #ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
                #endif

                return half4(Color, Alpha);
            }
            ENDHLSL
        }


        Pass
        {

            Name "DepthOnly"
            Tags
            {
                "LightMode"="DepthOnly"
            }

            ZWrite On
            ColorMask 0
            AlphaToMask Off

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1
            #define ASE_ABSOLUTE_VERTEX_POS 1
            #define ASE_SRP_VERSION 999999


            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"


            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
                #endif

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _RefractHueScaleOffset;
            float4 _ReflectHueScaleOffset;
            float4 _BaseColor;
            float _RefractPresent;
            float _RefractIndrectFactor;
            float _ReflectIndirect;
            float _Specular;
            float _SpecularPower;
            float _ReflectAlpha;
            #ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
            #endif
            CBUFFER_END


            VertexOutput VertexFunction(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


                #ifdef ASE_ABSOLUTE_VERTEX_POS
                float3 defaultVertexValue = v.vertex.xyz;
                #else
					float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                v.vertex.xyz = vertexValue;
                #else
					v.vertex.xyz += vertexValue;
                #endif

                v.ase_normal = v.ase_normal;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);

                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
                #endif

                o.clipPos = TransformWorldToHClip(positionWS);
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
                #endif
                return o;
            }

            #if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
            #if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
            #elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
            #elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
            #elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
            #endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
            #if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
            #endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
            #else
            VertexOutput vert(VertexInput v)
            {
                return VertexFunction(v);
            }
            #endif

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);

                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
                #endif
                #endif


                float Alpha = 1;
                float AlphaClipThreshold = 0.5;

                #ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
                #endif

                #ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
                #endif
                return 0;
            }
            ENDHLSL
        }


    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"

}