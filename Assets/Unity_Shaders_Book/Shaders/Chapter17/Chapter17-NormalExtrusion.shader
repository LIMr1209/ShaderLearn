// 表面着色器实例分析

Shader "Unity Shaders Book/Chapter 17/Normal Extrusion"
{
    Properties
    {
        _ColorTint ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BumpMap ("Normalmap", 2D) = "bump" {}
        _Amount ("Extrusion Amount", Range(-0.5, 0.5)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 300

        CGPROGRAM
        // surf - 表面函数
        // CustomLambert - 光照函数
        // vertex:myvert - 顶点修改函数
        // finalcolor:mycolor - 颜色修改函数
        // addshadow - 因为我们修改了顶点位置，所以shder需要特殊的阴影处理。 生成一个该表面着色器对应的阴影投射
        // exclude_path:deferred/exclude_path:prepass - 不要为延迟/遗留延迟渲染路径生成Pass
        // nometa - 取消对提取元数据的Pass的生成
        #pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow exclude_path:deferred exclude_path:prepass nometa
        #pragma target 3.0

        fixed4 _ColorTint;
        sampler2D _MainTex;
        sampler2D _BumpMap;
        half _Amount;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void myvert(inout appdata_full v)
        {
            // 使用顶点法线膨胀顶点位置
            v.vertex.xyz += v.normal * _Amount;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            // 使用主纹理设置表面属性的反射率
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb;
            o.Alpha = tex.a;
            // 使用法线纹理设置表面法线方向
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
        }

        half4 LightingCustomLambert(SurfaceOutput s, half3 lightDir, half atten)
        {
            // 实现兰伯特漫反射模型
            half NdotL = dot(s.Normal, lightDir);
            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
            c.a = s.Alpha;
            return c;
        }

        void mycolor(Input IN, SurfaceOutput o, inout fixed4 color)
        {
            // 混合主色
            color *= _ColorTint;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Diffuse"
}