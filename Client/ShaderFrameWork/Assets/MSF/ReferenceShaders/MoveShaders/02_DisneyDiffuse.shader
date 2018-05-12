Shader "Move/02_DisneyDiffuse"
{
	Properties
	{
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_Roughness ("Roughness",Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			#include "UnityCG.cginc"


			#define PI            3.14159265359f
			#define TWO_PI        6.28318530718f
			#define FOUR_PI       12.56637061436f
			#define INV_PI        0.31830988618f
			#define INV_TWO_PI    0.15915494309f
			#define INV_FOUR_PI   0.07957747155f
			#define HALF_PI       1.57079632679f
			#define INV_HALF_PI   0.636619772367f

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
				float4 lPos : TEXCOORD1;
			};

			float4 _MainColor;
			float _Roughness;

			float4 _LightColor0;
///---BRDF Function
			
			float Pow5 (float a)
			{
				return pow(a,5);
			}

			float BRDF_DisneyDiffuse(float3 In,float3 Out,float3 N,float roughness)
			{	
				//Compute useful variables
				float3 H = normalize(In + Out);

				float F_D90 = 0.5 + 2 * roughness * dot(H,In)*dot(H,In);

				float brdf = (1 + (F_D90-1)*Pow5(dot(N,In))* (1+(F_D90-1)*(1-Pow5(dot(N,Out))))) * INV_PI;

				return brdf;
			}

			

///---Vertex Function
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = v.normal;
	 			o.lPos = v.vertex;
				return o;
			}

///---Fragment Function
			float4 frag (v2f i) : SV_Target
			{
		
		///Define variables
				float4 wPos = mul(unity_ObjectToWorld,i.lPos);							//计算世界坐标
				float3 lightCol = _LightColor0.rgb;										//计算灯光颜色
				float3 normalDir = mul(i.normal,(float3x3)unity_WorldToObject);			//计算世界法线
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);					//计算灯光方向（入射光方向）
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos.xyz);		//计算视线方向（出射光方向）

				float NdotL = dot(normalDir,lightDir);


		///Uniform variables
				float3 Albedo = _MainColor.rgb;
				float Roughness = _Roughness;
				float Alpha = 1.0f;


		///Compute Color
				//L0(v) = PI * BRDF * lightCol * NdotL;
				//finCol = Albedo * L0(v);
				float3 L0v = UNITY_PI *  BRDF_DisneyDiffuse(lightDir,viewDir,normalDir,Roughness) * lightCol * NdotL;
				float3 finCol = Albedo * L0v;
				
				return float4(finCol,Alpha);
			}
			ENDCG
		}
	}
}
