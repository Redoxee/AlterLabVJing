// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "VJing/BigPath"
{
	Properties
	{
		_MainTex ("Sound Texture", 2D) = "white" {}
		_PrevFrame("Prev Frame",2D) = "white" {}
		_Resolution("Resolution", Vector) = (1,1,0,0)
		SFactor("Amplification",Float) = .05
	}
	SubShader
	{
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha

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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv - float2(.5,.5);
				float ratio = unity_OrthoParams.y / unity_OrthoParams.x;
				o.uv.x /= ratio;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _PrevFrame;
			float4 _Resolution;
#define NB_SAMPLE 8.
#define Smooth(p,r,s) smoothstep(-s, s, p-(r))

#define PI 3.14159
#define TPI (PI * 2.)
#define HPI (PI * .5)

			float SFactor = .05;

#define ALColor 140./255., 16./255., 34./255.
//#define ALColor SFactor,SFactor,SFactor

#define STEP 256
#define EPS .001


				// from various shader by iq

				float smin(float a, float b, float k)
			{
				float h = clamp(0.5 + 0.5*(b - a) / k, 0.0, 1.0);
				return lerp(b, a, h) - k*h*(1.0 - h);
			}

			const float2x2 m = float2x2(.8, -.6, .6, .8);

			float noise(in float2 x)
			{
				return sin(1.5*x.x)*sin(1.5*x.y);
			}

			float fbm6(float2 p)
			{
				float f = 0.0;
				f += 0.500000*(0.5 + 0.5*noise(p)); p = mul(m, p)*2.02;
				f += 0.250000*(0.5 + 0.5*noise(p)); p = mul(m, p)*2.03;
				f += 0.125000*(0.5 + 0.5*noise(p)); p = mul(m, p)*2.01;
				f += 0.062500*(0.5 + 0.5*noise(p)); p = mul(m, p)*2.04;
				f += 0.015625*(0.5 + 0.5*noise(p));
				return f / 0.96875;
			}


			float2x2 getRot(float a)
			{
				float sa = sin(a), ca = cos(a);
				return float2x2(ca, -sa, sa, ca);
			}


			float3 _position;

			float sphere(float3 center, float radius)
			{
				return distance(_position, center) - radius;
			}

			float hozPlane(float height)
			{
				return distance(_position.y, height);
			}

			float swingPlane(float height)
			{
				float3 pos = _position + float3(0., 0., _Time.y * 2.5);
				float def = fbm6(pos.xz * .25);

				float way = pow(abs(pos.x) * 16, 2.5) *.0000125;
				def *= way;

				float ch = height + def;
				return max(pos.y - ch, 0.);
			}

			float map(float3 pos)
			{
//				pos.z *= 2.;
				_position = pos;
				
				float dist;
				dist = swingPlane(0.);

				float sminFactor = 5.25;
				dist = smin(dist, sphere(float3(0., -15., 90.), 45.), sminFactor);
				return dist;
			}


			float3 getNormal(float3 pos)
			{
				float3 nor = float3(0., 0., 0.);
				float3 vv = float3(0., 1., -1.)*.01;
				nor.x = map(pos + vv.zxx) - map(pos + vv.yxx);
				nor.y = map(pos + vv.xzx) - map(pos + vv.xyx);
				nor.z = map(pos + vv.xxz) - map(pos + vv.xxy);
				nor /= 2.;
				return normalize(nor);
			}

			fixed4 frag(v2f i) : SV_Target
			{

				float radius = .25;
				float thickness = .0075;

				float2 uv = i.uv;

				float3 rayOrigin = float3(uv + float2(0., 6.), -1.);

				float3 rayDir = normalize(float3(uv, 1.));

				rayDir.zy = mul(getRot(.05) , rayDir.zy);
				rayDir.xy = mul(getRot(.075) , rayDir.xy);

				float3 position = rayOrigin;


				float curDist;
				int nbStep = 0;

				for (; nbStep < STEP; ++nbStep)
				{
					curDist = map(position);

					if (curDist < EPS)
						break;
					position += rayDir * curDist * .5;
				}

				float f;
				float sound = tex2D(_MainTex, float2(.0, .0)).r;
				sound = abs(sound);
				float dist = distance(rayOrigin, position);
				f = dist / (98.);
				f = float(nbStep) / float(STEP);

				f += pow(f, 4.) * (50. + sound * 50.);
				f *= .8;
				float4 col = float4(f, f, f, 1.);

				return col;
			}
			ENDCG
		}
	}
}
