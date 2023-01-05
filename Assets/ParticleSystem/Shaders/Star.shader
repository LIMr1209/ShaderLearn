// Made with Amplify Shader Editor v1.9.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Partical/Star"
{
	Properties
	{
		_EdgeWidth("EdgeWidth", Range( 0 , 1.5)) = 1.2
		[HDR]_EdgeColor("EdgeColor", Color) = (1,0,0,1)
		[HDR]_MainColor("MainColor", Color) = (0.1208298,0.2218085,5.336655,1)

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _MainColor;
			uniform float _EdgeWidth;
			uniform float4 _EdgeColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord1.zw = v.ase_texcoord1.xy;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 texCoord1 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float blendOpSrc2 = texCoord1.x;
				float blendOpDest2 = texCoord1.y;
				float temp_output_2_0 = ( saturate( abs( blendOpSrc2 - blendOpDest2 ) ));
				float blendOpSrc7 = texCoord1.x;
				float blendOpDest7 = ( 1.0 - texCoord1.y );
				float temp_output_7_0 = ( saturate( abs( blendOpSrc7 - blendOpDest7 ) ));
				float blendOpSrc8 = temp_output_2_0;
				float blendOpDest8 = temp_output_7_0;
				float blendOpSrc9 = temp_output_7_0;
				float blendOpDest9 = temp_output_2_0;
				float temp_output_10_0 = ( ( saturate( ( blendOpDest8/ max( 1.0 - blendOpSrc8, 0.00001 ) ) )) * ( saturate( ( blendOpDest9/ max( 1.0 - blendOpSrc9, 0.00001 ) ) )) );
				float2 texCoord23 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float temp_output_22_0 = ( 1.0 - texCoord23.x );
				float temp_output_13_0 = step( temp_output_10_0 , temp_output_22_0 );
				
				
				finalColor = ( ( _MainColor * temp_output_13_0 ) + ( ( step( pow( temp_output_10_0 , _EdgeWidth ) , temp_output_22_0 ) - temp_output_13_0 ) * _EdgeColor ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19100
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;347,19;Float;False;True;-1;2;ASEMaterialInspector;100;5;Partical/Star;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2653.391,-176.6682;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;2;-2224.219,-186.6514;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;6;-2406.303,2.545263;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;7;-2228.475,68.3538;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;8;-1919.973,-186.0391;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;9;-1920.022,68.57676;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1634.313,-69.70641;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1648.267,202.2239;Inherit;False;Property;_EdgeWidth;EdgeWidth;0;0;Create;True;0;0;0;False;0;False;1.2;1.2;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;11;-1334.7,80.93378;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;13;-1050.694,-112.2156;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-778.3401,46.35571;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;15;-1049.88,164.692;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-518.9518,249.4885;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-311.9199,-40.14894;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-525.4507,-166.3938;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;22;-1267.526,461.4476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1563.182,483.9063;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;20;-764.6506,-274.2938;Inherit;False;Property;_MainColor;MainColor;2;1;[HDR];Create;True;0;0;0;False;0;False;0.1208298,0.2218085,5.336655,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-747.9518,333.4885;Inherit;False;Property;_EdgeColor;EdgeColor;1;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;0;0;17;0
WireConnection;2;0;1;1
WireConnection;2;1;1;2
WireConnection;6;0;1;2
WireConnection;7;0;1;1
WireConnection;7;1;6;0
WireConnection;8;0;2;0
WireConnection;8;1;7;0
WireConnection;9;0;7;0
WireConnection;9;1;2;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;13;0;10;0
WireConnection;13;1;22;0
WireConnection;16;0;15;0
WireConnection;16;1;13;0
WireConnection;15;0;11;0
WireConnection;15;1;22;0
WireConnection;19;0;16;0
WireConnection;19;1;18;0
WireConnection;17;0;21;0
WireConnection;17;1;19;0
WireConnection;21;0;20;0
WireConnection;21;1;13;0
WireConnection;22;0;23;1
ASEEND*/
//CHKSM=215DFFDC0313335FDCA131AC3DB2B19397CCED65