Shader "VJing/FirstPass"
{
	Properties
	{
		_InputSound ("InputSound", 2D) = "white" {}
		_PastTex("Past",2D) = "white" {}
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
				float2 uvPast : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _InputSound;
			float4 _InputSound_ST;
			sampler2D _PastTex;
			float4 _PastTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _InputSound);
				o.uvPast = TRANSFORM_TEX(v.uvPast, _PastTex);
				return o;
			}

			float _Size = 1024.;

#define DEFIL (8. / _Size)

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;

				float now = tex2D(_InputSound, float2(uv.x, .0)).x;
				

				float4 col = float4(now,0.,0.,0.);

				float coordY = uv.y;
				if (coordY > DEFIL)
				{
					float pastY = coordY - DEFIL / 2.;

					col = tex2D(_PastTex, float2(uv.x, pastY));
				}

				return col;
			}
			ENDCG
		}
	}
}
