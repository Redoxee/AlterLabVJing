Shader "VJing/DisplayShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Resolution("Resolution", Vector) = (1,1,0,0)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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
#define NB_SAMPLE 1.
#define Smooth(p,r,s) smoothstep(-s, s, p-(r))

#define PI 3.14159
#define TPI (PI * 2.)
#define HPI (PI * .5)

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				//return tex2D(_MainTex, i.uv) * 5.;
				uv.x *= _Resolution.z;

				float2 center = float2(_Resolution.z / 2., .5);;

				float4 accumulator = float4(0.,0.,0.,0.);

				float2 uv_center = uv - center;

				float sampleX = atan2(uv_center.y, uv_center.x);
				sampleX = sampleX / TPI + .5;

				sampleX = frac(sampleX + _Time.y * .25);

				sampleX = abs(sampleX * 2. - 1.);
				sampleX = abs(sampleX * 2. - 1.);
				sampleX = abs(sampleX * 2. - 1.);


				float dist = length(uv_center) ;

				for (float j = 0; j < NB_SAMPLE; j += 1.)
				{
					accumulator += tex2D(_MainTex, float2(sampleX * .125, dist * .5 + j *.005));
				}
				accumulator /= NB_SAMPLE;

				float radius = .25;
				float thickness = .015;

				radius += accumulator.x * .6;

				float circle = 1. - Smooth(distance(radius, length(uv_center)), thickness, thickness * .1);

				float f = circle;
				float fade = 1. - pow(dist, 2.5) * 6.;
				f *= fade;
				float4 col = float4(1., 1., 1., 1.);
				if(f> 0.)
				 col = float4(f,0.,0.,1.);
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
