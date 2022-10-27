// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 逐顶点 光照 漫反射
Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            // pass 标签的一种 定义 光照流水线的角色
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 为了使用内置变量 需要 引入内置文件
            #include "Lighting.cginc"
            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                fixed3 color: COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // UNITY_LIGHTMODEL_AMBIENT 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // normalize 归一化
                // 顶点法线模型空间 转世界坐标空间 
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // _WorldSpaceLightPos0 光源方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //  saturate 把参数截取 到 0-1 
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                o.color = ambient * diffuse;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}