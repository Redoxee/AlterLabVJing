Shader "VJing/DisplayShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _Resolution;
#define NB_SAMPLE 8.
#define Smooth(p,r,s) smoothstep(-s, s, p-(r))

#define PI 3.14159
#define TPI (PI * 2.)
#define HPI (PI * .5)

			float SFactor = .05;

#define ALColor 140./255., 16./255., 34./255.
//#define ALColor SFactor,SFactor,SFactor


			// from http://iquilezles.org/www/articles/smin/smin.htm
			// polynomial smooth min (k = 0.1);
			float smin(float a, float b, float k)
			{
				float h = clamp(0.5 + 0.5*(b - a) / k, 0.0, 1.0);
				return lerp(b, a, h) - k*h*(1.0 - h);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float radius = .25;
				float thickness = .015;

				float2 uv = i.uv;
				//return tex2D(_MainTex, i.uv) * 5.;
				uv.x *= _Resolution.z;

				float2 center = float2(_Resolution.z / 2., .5);;

				float4 accumulator = float4(0.,0.,0.,0.);

				float2 uv_center = uv - center;

				float dist = length(uv_center);

				float sampleX = atan2(uv_center.y, uv_center.x);
				sampleX = sampleX / TPI + .5;
				sampleX += dist * .25;
				//sampleX += dist;
				sampleX = frac(sampleX + _Time.y * .025);

				sampleX = frac(sampleX * 2.);

				sampleX = abs(sampleX - .5) * 2.;

				float ignoreLeft = .05;
				sampleX = sampleX + ignoreLeft;
				sampleX = sampleX * (1. - ignoreLeft);
				sampleX *= .1;
				
				float sampleY = abs(dist - radius) * .5;
				float ripple = tex2D(_MainTex, float2(sampleX, sampleY)).r * SFactor * .5 / (dist * .5);

				radius += ripple;

				float decal = abs(tex2D(_MainTex, float2(sampleX,0.))).r * SFactor * .05;

				radius += decal;
				thickness += abs(tex2D(_MainTex, float2(0.05, 0.)).x) * SFactor * .2;

				float circle = 1. - Smooth(distance(radius, length(uv_center)), thickness, thickness * .1);

				float f = circle;
				float fade = 1. - pow(dist, 3.) * 6.;
				f *= fade;


				//float mt = tex2D(_MainTex, float2(sampleX, 0.)).r * 10.;
				//float dy = max(ddy(mt), 0.);
				//float dx = ddx(mt);
				float4 col = float4(ALColor, f);
				/*
				float lineIn = tex2D(_MainTex, float2(i.uv.x, 0.)).x * .125;
				lineIn = distance(uv.y - .5, lineIn);
				lineIn = 1. - Smooth(lineIn, .005, .005);
				if(length(uv_center) > radius+thickness )
					col += float4(lineIn, lineIn, lineIn, 0.);*/

				return col;
			}
			ENDCG
		}
	}
}
