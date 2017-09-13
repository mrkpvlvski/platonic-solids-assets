﻿Shader "Custom / Tetrahedron Edges" {

	Properties {

		_EdgeColor ("Edge Color", Color) = (1,1,1,1)
		_MainTex( "Texture", 2D) = "white" {}
		_Color013 ("Color013", Color) = (1,1,1,1)
		_Color013_2 ("Color013_2", Color) = (1,1,1,1)
		_Color012 ("Color012", Color) = (1,1,1,1)
		_Color023 ("Color023", Color) = (1,1,1,1)
		_Color132 ("Color132", Color) = (1,1,1,1)
		_Epsilon ("Epsilon", Range(0,1)) = 0.001
		_Delta ("Delta", Range(0,1)) = 0.01

	}


	Subshader {

		Pass {

			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
			#pragma exclude_renderers d3d11 gles

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			#define edge(j,k) step(length(pos-p[j]),_Epsilon)+step(length(pos-p[k]),_Epsilon)+step(length(pos-p[j]-dot(pos-p[j],p[k]-p[j])/length(p[k]-p[j])*(p[k]-p[j])/length(p[k]-p[j])),_Epsilon)*step(length(pos-p[j])+length(pos-p[k])-length(p[k]-p[j]),_Epsilon)

			float4 	_EdgeColor;
			float4 	_Color013;
			float4 	_Color013_2;
			float4 	_Color132;
			float4 	_Color012;
			float4 	_Color023;
			float 	_Epsilon;
			float 	_Delta;

			float w = 0.70710678118;
			float pi = 3.14159265359;




			float3 MxV (float3 col1, float3 col2, float3 col3, float3 v) {

				float m11 = col1.x;
				float m21 = col1.y;
				float m31 = col1.z;
				float m12 = col2.x;
				float m22 = col2.y;
				float m32 = col2.z;
				float m13 = col3.x;
				float m23 = col3.y;
				float m33 = col3.z;
				float v1 = v.x;
				float v2 = v.y;
				float v3 = v.z;

				return float3 (
					m11*v1+m12*v2+m13*v3,
					m21*v1+m22*v2+m23*v3,
					m31*v1+m32*v2+m33*v3
				);
			}


			float3 MINVxV (float3 col1, float3 col2, float3 col3, float3 v) {

				float m11 = col1.x;
				float m21 = col1.y;
				float m31 = col1.z;
				float m12 = col2.x;
				float m22 = col2.y;
				float m32 = col2.z;
				float m13 = col3.x;
				float m23 = col3.y;
				float m33 = col3.z;
				float v1 = v.x;
				float v2 = v.y;
				float v3 = v.z;

				float3 inv = float3 (
					(m22*m33-m23*m32)*v1+(m13*m32-m12*m33)*v2+(m12*m23-m13*m22)*v3,
					(m23*m31-m21*m33)*v1+(m11*m33-m13*m31)*v2+(m13*m21-m11*m23)*v3,
					(m21*m32-m22*m31)*v1+(m12*m31-m11*m32)*v2+(m11*m22-m12*m21)*v3
				);

				float det = m11*(m22*m33-m23*m32)-m12*(m21*m33-m23*m31)+m13*(m21*m32-m22*m31);

				return inv * pow(det,-1.0);
			}



			float3 P2Q(float3 _pt0, float3 _pt1, float3 _pt2, float3 v){


				float3 q0 = float3(-0.86602540378,-0.5,0);
				float3 q1 = float3(0,1,0);
				float3 q2 = float3(0.86602540378,-0.5,0);


				float3 inv = MINVxV(_pt0,_pt1,_pt2,v);

				return MxV(q0,q1,q2,inv);

			}




			struct Interpolators {
				float4 position : SV_POSITION;
				float3 localPosition : TEXCOORD0;

			};


			Interpolators MyVertexProgram (float4 position : POSITION) {
				Interpolators i;
				i.localPosition = position.xyz;
				i.position = UnityObjectToClipPos(position);
				return i;
			}

			float length(in float3 v, out float len){
			    len = pow(dot(v,v),0.5);
			    return len;
			}


			float4 MyFragmentProgram (Interpolators i) : SV_TARGET {

				float3 n013 = float3(0.0,-pow(2.0,0.5),1.0);
				float3 n012 = float3(0.0,pow(2.0,0.5),1.0); // orientation matters!
				float3 n023 = float3(pow(2.0,0.5),0.0,-1.0);
				float3 n132 = float3(-pow(2.0,0.5),0.0,-1.0);

				float3 p0 = float3(-1,0,-0.70710678118);
				float3 p1 = float3(1,0,-0.70710678118);
				float3 p2 = float3(0,-1,0.70710678118);
				float3 p3 = float3(0,1, 0.70710678118);

				float3 ptA = float3(-1.0,0.0,-pow(2.0,-0.5));
				float3 ptB = float3(1.0,0.0,-pow(2.0,-0.5));

				float3 pt013 = ptA;
				float3 pt012 = ptA;
				float3 pt023 = ptA;
				float3 pt132 = ptB;

				float3  p[4] =  {p0, p1, p2, p3};



				float3 localPosition = i.localPosition;

				float3 pos = localPosition;

		
				float3 fragColor = _EdgeColor*(	
					edge(0,1)+
					edge(0,2)+
					edge(0,3)+
					edge(1,2)+
					edge(1,3)+
					edge(2,3)
				);


				return float4(fragColor,1.0);

			}


			ENDCG

		}

	}
	
}