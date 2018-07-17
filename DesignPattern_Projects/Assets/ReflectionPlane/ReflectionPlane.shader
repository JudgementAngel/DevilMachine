Shader "Unlit/ReflectionPlane"
{
	Properties
	{
		_AlphaScale("透明度",Range(0,1)) = 1
		_ReflectionTex ("ReflectionTexture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
		

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
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
				float4 refl:TEXCOORD4;
			};

			sampler2D _ReflectionTex;
			float _AlphaScale;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.refl = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 reflCol = tex2Dproj(_ReflectionTex,i.refl);
				reflCol.a *= _AlphaScale;
				return reflCol;
			}
			ENDCG
		}
	}
}
