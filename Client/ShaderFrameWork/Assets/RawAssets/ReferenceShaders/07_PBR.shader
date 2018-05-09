Shader "Move/07_PBR"
{
	Properties
	{
        _MainColor("Main Color",Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white"{}
        _NormalTex ("Normal Tex",2D) = "bump"{}
        
        _Metallic ("Metallic ",Range(0,1)) = 1
		_Roughness ("Roughness",Range(0,1)) = 1
        _AmbientLightColor ("AmbientLight Color",Color) = (1,1,1,1)
        _AmbientLightIntsity ("AmbientLight Intensity",Range(0,1)) = 0
        _EnvMap("EnvMap",Cube) = "_Skybox"{}

        _Offset("Offset",float) = 0
        _LightIntensity("Light Intensity",Range(0,1)) = 1
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

            float _Offset;
        ///EnvMap
            samplerCUBE _EnvMap;
        ///Light
			float4 _LightColor0;
            float _LightIntensity;

///---My Image Based Lighting Function   

            float3 Specular_F_Roughness(float3 specularColor,float a ,float3 h,float3 v)
            {
                // Sclick using roughness to attenuate fresnel.
                return (specularColor + (max(1.0f-a, specularColor) - specularColor) * pow((1 - saturate(dot(v, h))), 5));
            }
   
            half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NdotV )
            {
                const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
                const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
                half4 r = Roughness * c0 + c1;
                half a004 = min( r.x * r.x, exp2( -9.28 * NdotV ) ) * r.x + r.y;
                half2 AB = half2( -1.04, 1.04 ) * a004 + r.zw;
                return SpecularColor * AB.x + AB.y;
            }

            half EnvBRDFApprox_Nonmetal( half Roughness, half NdotV )
            {
                // Same as EnvBRDFApprox( 0.04, Roughness, NdotV )
                const half2 c0 = { -1, -0.0275 };
                const half2 c1 = { 1, 0.0425 };
                half2 r = Roughness * c0 + c1;
                return min( r.x * r.x, exp2( -9.28 * NdotV ) ) * r.x + r.y;
            }

            float3 IBL_Approx(samplerCUBE EnvMap,float3 SpecularColor,float3 N,float3 L,float3 V,float Roughness)
            {
                float3 R = reflect(-V,N);
                float3 Li_u = texCUBE(EnvMap,R);
                float3 H = normalize(V + L);
                float NdotV = saturate(dot(N,V));
                float3 IBL = Li_u * EnvBRDFApprox(SpecularColor,Roughness,NdotV) * Specular_F_Roughness(SpecularColor,Roughness *Roughness,H,V);
                return IBL;
            }

///---CookTorrence Function
        ///Fresnel Function
            float3 Fresnel_Schlick(float3 specColor,float3 H,float3 V)
            {
                float VdotH = saturate(dot(V,H));
                float pow5OneMinusVdotH = pow((1 - VdotH),5);

                return specColor + (1 - specColor) * pow5OneMinusVdotH;
            }
        
        ///Normal Distribution Function
            float NDF_GGX(float roughness,float3 N,float3 H)
            {
                float a = roughness * roughness;

                float a2 = a * a;
                float NdotH = saturate(dot(N,H));
                float NdotH2 = NdotH*NdotH;

                float temp = NdotH2*(a2 - 1)+1;
                float denominator = PI * temp * temp;
                
                return a2 / denominator;
            }
        
        ///Geometric Shadowing-masking Function
            float GSF_Schlick_GGX(float roughness,float3 N,float3 L,float3 V)
            {
                float a = roughness * roughness;

                float k = a * 0.5f;

                float NdotV = saturate(dot(N,V));
                float denominator = NdotV * (1 - k) + k;
                float GV = NdotV / denominator;

                float NdotL = saturate(dot(N,L));
                denominator = NdotL * (1 - k) + k;
                float GL = NdotL / denominator;

                return GL * GV;
            }

            float Specular_G(float a, float NdV, float NdL, float NdH, float VdH, float LdV)
            {
                    // Smith schlick-GGX.
                float k = a * 0.5f;
                float GV = NdV / (NdV * (1 - k) + k);
                float GL = NdL / (NdL * (1 - k) + k);

                return GV * GL;
            }


///---BRDF Function
		
            float3 Specular_BRDF_Torrence_Sparrow(float3 L,float3 V,float3 N,float3 specColor,float roughness)
            {
                float NdotL = saturate(dot(N,L));
                float NdotV = saturate(dot(N,V));
                float3 H = normalize(L + V);

                float3 Fresnel = Fresnel_Schlick(specColor,H,V);
                float NDF = NDF_GGX(roughness,N,H);
                float GSF = GSF_Schlick_GGX(roughness,N,L,V);

                float denominator = 4 * NdotL * NdotV +0.001f;

                float3 specularColor = Fresnel * GSF * NDF / denominator;
                return specularColor;
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
                float NormalizeNdotL = dot(normalDir,lightDir)*0.5f + 0.5f;

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
                Specular = saturate(Specular);
            ///Ambient Light
                float3 Ambient =  _AmbientLightIntsity * baseColor  * _AmbientLightColor ;

            ///IBL
                //(SamplerCUBE EnvMap,float3 SpecularColor,float3 N,float3 L,float3 V,float Roughness)
                float3 IBLColor = IBL_Approx(_EnvMap,specColor,normalDir,lightDir,viewDir,roughness);// *  NdotL;

            ///Finally Color
            	float3 finCol =  Diffuse+ Specular;
                finCol *= _LightIntensity;
                finCol += IBLColor;
                finCol = saturate(finCol)  +  Ambient  ;
                
				return float4(finCol,Alpha);
			}
			ENDCG
		}
	}
    FallBack "Diffuse"
}
