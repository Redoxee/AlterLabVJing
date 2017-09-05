Shader "VJing/SpherePass"
{
	Properties
	{
		_InputSound ("InputSound", 2D) = "white" {}
		_SkyBox("Sky",3D) = "white" {}
		_Size("Size",Float) = 1024.
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uvPast : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _InputSound;
			float4 _InputSound_ST;
			sampler3D _SkyBox;
			float4 _SkyBoxST_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _InputSound);
				return o;
			}

			float _Size = 1024.;

#define iTime _Time.y

			// Original Shader by aiekick
			// https://www.shadertoy.com/view/4t2SWW
			// Remixed by Anton

			float dstef = 0.0;

			// The MIT License
			// Copyright © 2015 Inigo Quilez
			// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
			float3 pal(in float t, in float3 a, in float3 b, in float3 c, in float3 d)
			{
				return a + b*cos(6.28318*(c*t + d));
			}

			float3 iqGrad(float f)
			{
				return pal(f, float3(0.5, 0.5, 0.5), float3(0.5, 0.5, 0.5), float3(1.0, 1.0, 0.5), float3(0.8, 0.90, 0.30));
			}

			// based on my 2d shader https://www.shadertoy.com/view/llSSWD
			float3 effect(float2 g)
			{
				float t = iTime * 1.5;
				g /= 50.;
				g.x += 0.55;
				g.y += .1;

				g.x += sin(g.y *15. + t*.2) * .05;

				//float inputTex = textureLod(iChannel1, g, 2. + 4.*(sin(t)*.5 + .5)).r;
				float inputTex = tex2D(_InputSound, g).r;
				float3 c = tex2D(_InputSound, g).rrr;//iqGrad(1. - inputTex);
				c = smoothstep(c + .5, c, float3(.71, .71, .71));
				return c;
			}

			/*float2 rot(float2 s, float a)
			{
				float sa = sin(a); float ca = cos(a);
				return float2x2(ca, -sa, sa, ca) * s;
			}*/

			///////FRAMEWORK////////////////////////////////////
#define mPi 3.14159
#define m2Pi 6.28318
			float2 uvMap(float3 p)
			{
				p = normalize(p);

				float2 tex2DToSphere3D;
				tex2DToSphere3D.x = 0.5 + atan2(p.z, p.x) / m2Pi;
				tex2DToSphere3D.y = 0.5 - asin(p.y) / mPi;
				return tex2DToSphere3D;
			}

			float4 displacement(float3 p)
			{
				float3 col = effect(p.xz);

				col = clamp(col, float3(0,0,0), float3(1.,1.,1.));
				float dist = dot(col, float3(.3,.3,.3));

				return float4(dist, col);
			}

			////////BASE OBJECTS///////////////////////
			float obox(float3 p, float3 b) { return length(max(abs(p) - b, 0.0)); }
			float osphere(float3 p, float r) { return length(p) - r; }
			////////MAP////////////////////////////////
			float4 map(float3 p)
			{
				float scale = 1.; // displace scale
				float dist = 0.;

				float x = 6.;
				float z = 6.;

				float4 disp = displacement(p);

				float y = 1. - smoothstep(0., 1., disp.x) * scale;

				dist = osphere(p, +5. - y);

				return float4(dist, disp.yzw);
			}

			float3 calcNormal(in float3 pos, float prec)
			{
				float3 eps = float3(prec, 0., 0.);
				float3 nor = float3(
					map(pos + eps.xyy).x - map(pos - eps.xyy).x,
					map(pos + eps.yxy).x - map(pos - eps.yxy).x,
					map(pos + eps.yyx).x - map(pos - eps.yyx).x);
				return normalize(nor);
			}

			float calcAO(in float3 pos, in float3 nor)
			{
				float occ = 0.0;
				float sca = 1.0;
				for (int i = 0; i<5; i++)

				{
					float hr = 0.01 + 0.12*float(i) / 4.0;
					float3 aopos = nor * hr + pos;
					float dd = map(aopos).x;
					occ += -(dd - hr)*sca;
					sca *= 0.95;
				}
				return clamp(1.0 - 3.0*occ, 0.0, 1.0);
			}

			////////MAIN///////////////////////////////
			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;

				//float2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
				//uv.x *= iResolution.x / iResolution.y;

				float cam_a = -1.7; // angle z

				float cam_e = 8.; // elevation
				float cam_d = 4.; // distance to origin axis

				float3 camUp = float3(0, 1, 0);//Change camere up vector here
				float3 camView = float3(0, 0, 0); //Change camere view here
				float li = 0.6; // light intensity
				float prec = 0.00001; // ray marching precision
				float maxd = 50.; // ray marching distance max
				float refl_i = .6; // reflexion intensity
				float refr_a = 1.2; // refraction angle
				float refr_i = .8; // refraction intensity
				float bii = 0.35; // bright init intensity
				float marchPrecision = 0.25; // ray marching tolerance precision

											 /////////////////////////////////////////////////////////

				float swingTime = iTime;
				cam_e = (sin(swingTime * .2) * 3.) + 8.;


				/////////////////////////////////////////////////////////


				float3 col = float3(0.,0.,0.);

				float3 ro = float3(-sin(cam_a)*cam_d, cam_e + 1., cos(cam_a)*cam_d); //
				float3 rov = normalize(camView - ro);
				float3 u = normalize(cross(camUp, rov));
				float3 v = cross(rov, u);
				float3 rd = normalize(rov + uv.x*u + uv.y*v);

				float b = bii;

				float d = 0.;
				float3 p = ro + rd*d;
				float s = prec;
				//rd.xz = rot(rd.xz,1.7);
				float3 ray, cubeRay;

				for (int i = 0; i<250; i++)
				{
					if (s<prec || s>maxd) break;
					s = map(p).x*marchPrecision;
					d += s;
					p = ro + rd*d;
				}

				if (d<maxd)
				{
					float2 e = float2(-1., 1.)*0.005;
					float3 n = calcNormal(p, 0.1);

					b = li;

					ray = reflect(rd, n);
					cubeRay = tex3D(_SkyBox, ray).rgb  * refl_i;

					ray = refract(ray, n, refr_a);
					cubeRay += tex3D(_SkyBox, ray).rgb * refr_i;

					col = cubeRay + pow(b, 15.);


					// lighting        
					float occ = calcAO(p, n);
					float3  lig = normalize(float3(-0.6, 0.7, -0.5));
					float amb = clamp(0.5 + 0.5*n.y, 0.0, 1.0);
					float dif = clamp(dot(n, lig), 0.0, 1.0);
					float bac = clamp(dot(n, normalize(float3(-lig.x, 0.0, -lig.z))), 0.0, 1.0)*clamp(1.0 - p.y, 0.0, 1.0);
					float dom = smoothstep(-0.1, 0.1, cubeRay.y);
					float fre = pow(clamp(1.0 + dot(n, rd), 0.0, 1.0), 2.0);
					float spe = pow(clamp(dot(cubeRay, lig), 0.0, 1.0), 16.0);

					float3 brdf = float3(0.,0.,0.);
					brdf += 1.20*dif*float3(1.00, 0.90, 0.60);
					brdf += 1.20*spe*float3(1.00, 0.90, 0.60)*dif;
					brdf += 0.30*amb*float3(0.50, 0.70, 1.00)*occ;
					brdf += 0.40*dom*float3(0.50, 0.70, 1.00)*occ;
					brdf += 0.30*bac*float3(0.25, 0.25, 0.25)*occ;
					brdf += 0.40*fre*float3(1.00, 1.00, 1.00)*occ;
					brdf += 0.02;
					col = col*brdf;

					col = lerp(col, float3(0.8, 0.9, 1.0), 1.0 - exp(-0.0005*d*d));

					col = lerp(col, map(p).yzw, 0.5);

				}
				else
				{
					col = tex3D(_SkyBox, rd).rgb;
				}


				return fixed4(0., 0., 0., 0.);
				//return float4(col.rgb,1.);
			}
			ENDCG


		}
	}
}
