Shader "Move/05_CookTorrence"
{
	Properties
	{
        _MainColor("Main Color",Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white"{}
        _NormalTex ("Normal Tex",2D) = "bump"{}
        _Metallic ("Metallic ",Range(0,1)) = 1
		_Roughness ("Roughness",Range(0,1)) = 1
        _AmbientLightColor ("AmbientLight Color",Color) = (1,1,1,1)
        _AmbientLightIntsity ("AmbientLight Intensity",Range(0,10)) = 0
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
            //#include "Move.cginc"

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
                float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
				float4 lPos : TEXCOORD1;

                float4 tangent : TANGENT;
			};
///---Variables
			///Main
            float4 _MainColor;
			sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalTex;
            float4 _NormalTex_ST;
			float _Metallic;
            float _Roughness;
        
        ///Ambient Light
            float4 _AmbientLightColor;
            float _AmbientLightIntsity;

        ///Light
			float4 _LightColor0;

///---CookTorrence Function
        ///Fresnel Function
            float3 Fresnel_Schlick(float3 specColor,float3 H,float3 V)
            {
                float VdotH = saturate(dot(V,H));
                float pow5OneMinusVdotH = pow((1 - VdotH),5);

                return specColor + (1 - specColor) * pow5OneMinusVdotH;
            }
        
        ///Normal Distribution Function
            float NDF_GGX(float a,float3 N,float3 H)
            {
                float a2 = a * a;
                float NdotH = saturate(dot(N,H));
                float NdotH2 = NdotH*NdotH;

                float temp = NdotH2*(a2 - 1)+1;
                float denominator = PI * temp * temp;
                
                return a2 / denominator;
            }
        
        ///Geometric Shadowing-masking Function
            float GSF_Schlick_GGX(float a,float3 N,float3 L,float3 V)
            {
                float k = a * 0.5f;

                float NdotV = saturate(dot(N,V));
                float denominator = NdotV * (1 - k) + k;
                float GV = NdotV / denominator;

                float NdotL = saturate(dot(N,L));
                denominator = NdotL * (1 - k) + k;
                float GL = NdotL / denominator;

                return GL * GV;
            }


///---BRDF Function
		
            float3 Specular_BRDF_Torrence_Sparrow(float3 L,float3 V,float3 N,float3 specColor,float roughness)
            {
                float a = roughness * roughness;
                float NdotL = saturate(dot(N,L));
                float NdotV = saturate(dot(N,V));
                float3 H = normalize(L + V);

                float3 Fresnel = Fresnel_Schlick(specColor,H,V);
                float NDF = NDF_GGX(a,N,H);
                float GSF = GSF_Schlick_GGX(a,N,L,V);

                float denominator = 4 * NdotL * NdotV ;

                return Fresnel * GSF * NDF / denominator;
            }
///---Vertex Function
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = v.normal;
	 			o.lPos = v.vertex;
                o.tangent = v.tangent;
				return o;
			}

///---Fragment Function
			float4 frag (v2f i) : SV_Target
			{
		
		///Define variables
                //Normal
                float3 wNormal = normalize(mul(i.normal,(float3x3)unity_WorldToObject));
                float3 wTangent = normalize(mul((float3x3)unity_ObjectToWorld,i.tangent.xyz));
                float3 wBinormal = normalize(cross(wNormal, wTangent) * i.tangent.w); 
                float3x3 TangentToWorld = float3x3(wTangent,wBinormal,wNormal);

                float3 normalTex = UnpackNormal(tex2D(_NormalTex,i.uv*_NormalTex_ST.xy + _NormalTex_ST.zw));
                                

				float4 wPos = mul(unity_ObjectToWorld,i.lPos);							
				float3 lightCol = _LightColor0.rgb;										
				float3 normalDir = normalize(mul(normalTex, TangentToWorld));
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);					
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos.xyz);		


				float NdotL = max(0,dot(normalDir,lightDir));


		///Uniform variables
				float metallic = _Metallic;
				float roughness = max(0.001f, _Roughness);

				float3 baseColor = tex2D(_MainTex , i.uv * _MainTex_ST.xy + _MainTex_ST.zw).xyz;
				float3 specColor = lerp(0.04f.rrr, baseColor, metallic);
				baseColor = lerp(baseColor, 0.0f.rrr, metallic) * _MainColor;
				
				float Alpha = 1.0f;


		///Compute Color
				//L0(v) = PI * BRDF * lightCol * NdotL;
				//finCol = Albedo * L0(v);
            
            ///Diffuse
				float3 Diffuse = lightCol * NdotL;
                Diffuse *= baseColor;
            ///Specular
                float3 Specular = PI * lightCol * NdotL * 
                    Specular_BRDF_Torrence_Sparrow(lightDir,viewDir,normalDir,specColor,roughness);
                //Specular = max(0,Specular);
            ///Ambient Light
                float3 Ambient =  _AmbientLightIntsity * baseColor  * _AmbientLightColor ;

            ///Finally Color
            	float3 finCol =  Diffuse + Specular;
                finCol = saturate(finCol)  +  Ambient;
                
				return float4(finCol,Alpha);
			}
			ENDCG
		}
	}
    FallBack "Diffuse"
}
