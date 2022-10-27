Shader "Unity Shaders Book/Chapter 17/Bumped Diffuse" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		// #pragma surface surfaceFunction lightModel [optionalparams]
		// #pragma surface 表明用于表面着色器 后面指定表面函数和光照函数  ,还可以有一些可选参数
		// 光照函数 使用表面函数设置的属性 来应用光照模型
		// 可选参数  有透明度测试 透明度混合  顶点修改函数 颜色修改函数
		#pragma surface surf Lambert
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		// 表面函数 
		// SurfaceOutput SurfaceOutputStandard SurfaceOutputStandardSpecular 都是 内置的结构体
		// Input IN 输入结构体 设置各种表面属性
		// 属性存储在 SurfaceOutput 输出结构体中
		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color.rgb;
			o.Alpha = tex.a * _Color.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}
		
		ENDCG
	} 
	
	FallBack "Legacy Shaders/Diffuse"
}
