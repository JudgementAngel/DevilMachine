Shader "Move/04_Phong"
{
	Properties
	{
		_MainColor ("Main Color", Color) = (1,1,1,1)
        _SpecColor ("Specular Color",Color) = (1,1,1,1)
        _SpecPow ("Specular Pow",Float) = 1
		_Roughness ("Roughness",Range(0,1)) = 1
        _AmbientLightColor ("AmbientLight Color",Color) = (1,1,1,1)
        _AmbientLightIntsity ("AmbientLight Intensity",Range(0,1)) = 0
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
        
        ///Main
			float4 _MainColor;
            float4 _SpecColor;
			float _SpecPow;
            float _Roughness;
        
        ///Ambient Light
            float4 _AmbientLightColor;
            float _AmbientLightIntsity;

        ///Light
			float4 _LightColor0;

///---BRDF Function
		///Diffuse BRDF
			float BRDF_Lambertian(float3 In,float3 Out)
            {
                // 乘以PI的倒数是因为BRDF在半球内的积分需要为1，满足能量守恒
                return INV_PI;
            }

		///Specular BRDF
            float BRDF_Phong(float3 In,float3 Out,float3 N,float specPow)
            {
                //归一化因子
                float normalizationFactor = (specPow + 2)/(2*PI);
                return pow(max(0,dot(Out,normalize(reflect(-In,N)))),specPow) * normalizationFactor;
            }

            float BRDF_Phong1(float3 In,float3 Out,float3 N,float specPow)
            {
                //归一化因子
                float normalizationFactor = (specPow + 1)/(2*PI);
                return pow(max(0,dot(Out,normalize(reflect(-In,N)))),specPow) * normalizationFactor;
            }
                
            float Experience_Phong(float3 In,float3 Out,float3 N,float specPow)
            {
                return pow(max(0,dot(reflect(-In, N),Out)),specPow);
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
				float4 wPos = mul(unity_ObjectToWorld,i.lPos);							
				float3 lightCol = _LightColor0.rgb;										
				float3 normalDir = mul(i.normal,(float3x3)unity_WorldToObject);			
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);					
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos.xyz);		


				float NdotL = dot(normalDir,lightDir);


		///Uniform variables
				float3 Albedo = _MainColor.rgb;
				float Roughness = _Roughness;
				float Alpha = 1.0f;


		///Compute Color
				//L0(v) = PI * BRDF * lightCol * NdotL;
				//finCol = Albedo * L0(v);
            
            ///Diffuse
				float3 Diffuse = UNITY_PI *  BRDF_Lambertian(lightDir,viewDir) * lightCol * NdotL;
                Diffuse *= Albedo;

            ///Specular
                //0
                float3 Specular = UNITY_PI * BRDF_Phong(lightDir,viewDir,normalDir,_SpecPow) * lightCol * NdotL;
                Specular *= _SpecColor;
                //1
                float3 Specular1 = UNITY_PI * BRDF_Phong1(lightDir,viewDir,normalDir,_SpecPow)  * lightCol;
                Specular1 *= _SpecColor;
                //2
                float3 Specular2 = Experience_Phong(lightDir,viewDir,normalDir,_SpecPow)  * lightCol ;
                Specular2 *= _SpecColor;

            ///Ambient Light
                float3 Ambient =  _AmbientLightIntsity * Albedo * _AmbientLightColor;

            ///Finally Color
            	float3 finCol =  Diffuse + Specular2 + Ambient;
                
				return float4(finCol,Alpha);
			}
			ENDCG
		}
	}
}
