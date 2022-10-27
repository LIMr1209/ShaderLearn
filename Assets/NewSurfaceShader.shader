Shader "Unlit/Texture Cyberpunk"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Power("Power", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct a2v 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Power;

			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 baseTex = tex2D(_MainTex, i.texcoord);
				float3 xyz = baseTex.rgb;
				float oldx = xyz.x;
				float oldy = xyz.y;
				float add = abs(oldx - oldy)*0.5;
				float stepxy = step(xyz.y, xyz.x);
				float stepyx = 1 - stepxy;
				xyz.x = stepxy * (oldx + add) + stepyx * (oldx - add);
				xyz.y = stepyx * (oldy + add) + stepxy * (oldy - add);
				xyz.z = sqrt(xyz.z);
				baseTex.rgb = lerp(baseTex.rgb, xyz, _Power);
				return baseTex;
			}
			ENDCG
		}
	}
	Fallback off
}