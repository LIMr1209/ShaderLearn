Shader "Hidden/Special/Lamina/Depth"
{
    Properties
    {
        _ColorA("_ColorA (default = 1,1,1,1)", Color) = (1,1,1,1)
        _ColorB("_ColorB (default = 0,0,0,1)", Color) = (0,0,0,1)
        [ShowAsVector3] _Origin("Origin", Vector) = (0,0,1,0)
        _Alpha("Alpha (default = 1)", range(0,1)) = 1
        _Far("Far", float) = 0
        _Near("Near", float) = 100
        
        
        [Enum(DepthMappingEnum)]_Mapping("Mapping", Int) = 0
        
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

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            half4 _ColorA;
            half4 _ColorB;
            half _Alpha;
            half3 _Origin;
            half _Far;
            half _Near;
            int _Mapping;


            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float f_dist;
                if(_Mapping == 0)
                {
                    f_dist = length(i.worldPos - _Origin);
                }
                else if(_Mapping == 1)
                {
                    f_dist = length(i.vertex);
                }else
                {
                     f_dist = length(i.worldPos - _WorldSpaceCameraPos);
                }
                float f_depth = (f_dist - _Near) / (_Far - _Near);
                half3 f_depthColor = lerp(_ColorB, _ColorA, 1.0 - clamp(f_depth, 0., 1.));
                return half4(f_depthColor, _Alpha);
            }
            ENDCG
        }
    }
}