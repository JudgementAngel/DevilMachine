Shader "MSF/Shader_Test1"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Bump Map",2D) = "bump" {}
		_SpecularGlossMap("Specular+Gloss", 2D) = "white" {}
		_MetallicTex ("Metallic",2D) = "white"{}
		_RoughnessTex ("Roughness",2D) = "white"{}
		_LUT ("Look Up Table",2D) = "white"{}
		_IBL ("ImageBasedLighting",CUBE) = ""{}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase_fullshadows

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 T2W0 : TEXCOORD1;
				float4 T2W1 : TEXCOORD2;
				float4 T2W2 : TEXCOORD3;
				float3 viewDir : TEXCOORD4;
				float3 lightDir : TEXCOORD5;
				LIGHTING_COORDS(6,7)
			};

			sampler2D _MainTex;fixed4 _MainTex_ST;
			sampler2D _BumpMap;
			sampler2D _SpecularGlossMap;
			sampler2D _MetallicTex,_RoughnessTex;
			sampler2D _LUT;
			samplerCUBE _IBL;		
			
			float G1V(float nx ,float k)
			{
				return 1.0f / (nx * (1.0f - k) + k);
			}
			
			float3 GGX_Specular(float nl, float nv,float nh,float lh,float3 H,float roughness,float3 specular)
			{
				float a = roughness;
				float a2 = a*a;
				float denom = nh * nh * (a2 - 1.0f)+1.0;
				float D = a2 / (UNITY_PI * denom * denom);
				float3 F = specular + (1.0f.xxx-specular)*Pow5(1.0f - lh);

				float k = a * 0.5f;
				float G = G1V(nl,k) * G1V(nv,k);

				return nl * D * F * G;
			}

			float3 Diffuse_Burley(float3 diffuseCol,float roughness,float nv,float nl,float vh)
			{
				float FD90 = 0.5 + 2 * vh*vh*roughness;
				float FdV = 1 + (FD90 - 1) * Pow5(1 - nv);
				float FdL = 1 + (FD90 - 1) * Pow5(1 - nl);
				return diffuseCol * ((1/UNITY_PI) * FdV * FdL);
			}

			half3 EnvBRDF(sampler2D nv_roughness, half3 specularCol ,half roughness ,half nv)
			{
				float2 AB = tex2Dlod(nv_roughness,float4(nv,roughness,0,0)).rg;
				float3 GF = specularCol * AB.x + saturate(50.0 * specularCol) * AB.y;
				return GF;
			}

			half ComputeCubemapMipFromRoughness(half roughness,half mipCount)
			{
				half level = 3 - 1.15 * log2(roughness);
				return mipCount -1-level;
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				TANGENT_SPACE_ROTATION;

				half3 wN = UnityObjectToWorldNormal(v.normal);
				half3 wT = UnityObjectToWorldDir(v.tangent.xyz);
				half3 wBN = cross(wN,wT) * v.tangent.w;
				half3 wPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				o.T2W0 = half4(wT.x,wBN.x,wN.x,wPos.x);
				o.T2W1 = half4(wT.y,wBN.y,wN.y,wPos.y);
				o.T2W2 = half4(wT.z,wBN.z,wN.z,wPos.z);

				o.lightDir = WorldSpaceLightDir(v.vertex);
				o.viewDir = WorldSpaceViewDir(v.vertex);

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half3 normal = UnpackNormal(tex2D(_BumpMap,i.uv));
				half3 wNormalDir = normalize(half3(dot(i.T2W0.xyz,normal),dot(i.T2W1.xyz,normal),dot(i.T2W2.xyz,normal)));
				half3 wViewDir = normalize(i.viewDir);
				half3 wLightDir = normalize(i.lightDir);
				half3 wHalfDir = normalize(wLightDir + wViewDir);

				half NdotL = saturate(dot(wNormalDir,wLightDir));
				half NdotV = saturate(dot(wNormalDir,wViewDir));
				half LdotH = saturate(dot(wHalfDir,wLightDir));
				half NdotH = saturate(dot(wNormalDir,wHalfDir));
				half VdotH = saturate(dot(wViewDir,wHalfDir));

				half3 wReflect = 2 * NdotV * wNormalDir - wViewDir;

				float4 m = tex2D(_MetallicTex,i.uv);
				float4 mainTex = tex2D(_MainTex,i.uv);
				float metallic = m.r;

				float4 diffuseCol = mainTex - mainTex * metallic;
				float4 specularCol = lerp(0.3f,mainTex,metallic);
				
				float4 r = tex2D(_RoughnessTex,i.uv);
				float roughness = r.r;

				float3 specular = GGX_Specular(NdotL,NdotV,NdotH,LdotH,wHalfDir,roughness,specularCol.rgb);

				// float3 lambertDiffuse = diffuseCol * NdotL;
				// float3 halfLambertDiffuse = diffuseCol * (NdotL * 0.5 + 0.5);
				float3 burleyDiffuse = Diffuse_Burley(diffuseCol,roughness,NdotV,NdotL,VdotH);

				float atten = LIGHT_ATTENUATION(i);

				float iblDiffuseMip = ComputeCubemapMipFromRoughness(roughness,3) + 7;
				half3 iblDiffuseCol = texCUBElod(_IBL,float4(wNormalDir.xyz,iblDiffuseMip)).rgb;

				float iblSpecularMip = ComputeCubemapMipFromRoughness(roughness,10);
				half3 iblSpecularCol = texCUBElod(_IBL,float4(wReflect.xyz,iblSpecularMip)).rgb;
				half3 iblSpecularBRDF = EnvBRDF(_LUT,specularCol.rgb,roughness,NdotV);

				fixed4 finCol = 1.0f.xxxx;
				finCol.rgb = burleyDiffuse + specular * _LightColor0.rgb * atten + iblSpecularCol * iblSpecularBRDF * specularCol.rgb + iblDiffuseCol * diffuseCol.rgb;

				// finCol.rgb = (specular + lambertDiffuse + UNITY_LIGHTMODEL_AMBIENT.rgb) * _LightColor0 * atten + iblSpecularCol * iblSpecularBRDF * specularCol.rgb + iblDiffuseCol * diffuseCol.rgb

				// finCol.rgb = (specular + halfLambertDiffuse ) * _LightColor0 * atten + iblSpecularCol * iblSpecularBRDF * specularCol.rgb + iblDiffuseCol * diffuseCol.rgb
				return finCol;
			}
			ENDCG
		}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase_fullshadows

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 T2W0 : TEXCOORD1;
				float4 T2W1 : TEXCOORD2;
				float4 T2W2 : TEXCOORD3;
				float3 viewDir : TEXCOORD4;
				float3 lightDir : TEXCOORD5;
				LIGHTING_COORDS(6,7)
			};

			sampler2D _MainTex;fixed4 _MainTex_ST;
			sampler2D _BumpMap;fixed4 _BumpMap_ST;
			sampler2D _SpecularGlossMap;fixed4 _SpecularGlossMap_ST;
			sampler2D _LUT;
			samplerCUBE _IBL;		
			
			float G1V(float nx ,float k)
			{
				return 1.0f / (nx * (1.0f - k) + k);
			}
			
			float3 GGX_Specular(float nl, float nv,float nh,float lh,float3 H,float roughness,float3 specular)
			{
				float a = roughness;
				float a2 = a*a;
				float denom = nh * nh * (a2 - 1.0f)+1.0;
				float D = a2 / (UNITY_PI * denom * denom);
				float3 F = specular + (1.0f.xxx-specular)*Pow5(1.0f - lh);

				float k = a * 0.5f;
				float G = G1V(nl,k) * G1V(nv,k);

				return nl * D * F * G;
			}

			float3 Diffuse_Burley(float3 diffuseCol,float roughness,float nv,float nl,float vh)
			{
				float FD90 = 0.5 + 2 * vh*vh*roughness;
				float FdV = 1 + (FD90 - 1) * Pow5(1 - nv);
				float FdL = 1 + (FD90 - 1) * Pow5(1 - nl);
				return diffuseCol * ((1/UNITY_PI) * FdV * FdL);
			}

			half3 EnvBRDF(sampler2D nv_roughness, half3 specularCol ,half roughness ,half nv)
			{
				float2 AB = tex2Dlod(nv_roughness,float4(nv,roughness,0,0)).rg;
				float3 GF = specularCol * AB.x + saturate(50.0 * specularCol) * AB.y;
				return GF;
			}

			half ComputeCubemapMipFromRoughness(half roughness,half mipCount)
			{
				half level = 3 - 1.15 * log2(roughness);
				return mipCount -1-level;
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				TANGENT_SPACE_ROTATION;

				half3 wN = UnityObjectToWorldNormal(v.normal);
				half3 wT = UnityObjectToWorldDir(v.tangent.xyz);
				half3 wBN = cross(wN,wT) * v.tangent.w;
				half3 wPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				o.T2W0 = half4(wT.x,wBN.x,wN.x,wPos.x);
				o.T2W1 = half4(wT.y,wBN.y,wN.y,wPos.y);
				o.T2W2 = half4(wT.z,wBN.z,wN.z,wPos.z);

				o.lightDir = WorldSpaceLightDir(v.vertex);
				o.viewDir = WorldSpaceViewDir(v.vertex);

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half3 normal = UnpackNormal(tex2D(_BumpMap,i.uv));
				half3 wNormalDir = normalize(half3(dot(i.T2W0.xyz,normal),dot(i.T2W1.xyz,normal),dot(i.T2W2.xyz,normal)));
				half3 wViewDir = normalize(i.viewDir);
				half3 wLightDir = normalize(i.lightDir);
				half3 wHalfDir = normalize(wLightDir + wViewDir);

				half NdotL = saturate(dot(wNormalDir,wLightDir));
				half NdotV = saturate(dot(wNormalDir,wViewDir));
				half LdotH = saturate(dot(wHalfDir,wLightDir));
				half NdotH = saturate(dot(wNormalDir,wHalfDir));
				half VdotH = saturate(dot(wViewDir,wHalfDir));

				half3 wReflect = 2 * NdotV * wNormalDir - wViewDir;

				float4 specularCol = tex2D(_SpecularGlossMap,i.uv);
				float4 diffuseCol = tex2D(_MainTex,i.uv);
				
				// specularCol.rgb = GammaToLinearSpace(specularCol.rgb);
				// diffuseCol.rgb = GammaToLinearSpace(diffuseCol.rgb);
				
				float roughness = 1 - specularCol.a;

				float3 specular = GGX_Specular(NdotL,NdotV,NdotH,LdotH,wHalfDir,roughness,specularCol.rgb);

				// float3 lambertDiffuse = diffuseCol * NdotL;
				// float3 halfLambertDiffuse = diffuseCol * (NdotL * 0.5 + 0.5);
				float3 burleyDiffuse = Diffuse_Burley(diffuseCol,roughness,NdotV,NdotL,VdotH);

				float atten = LIGHT_ATTENUATION(i);

				float iblDiffuseMip = ComputeCubemapMipFromRoughness(roughness,3) + 7;
				half3 iblDiffuseCol = texCUBElod(_IBL,float4(wNormalDir.xyz,iblDiffuseMip)).rgb;

				float iblSpecularMip = ComputeCubemapMipFromRoughness(roughness,10);
				half3 iblSpecularCol = texCUBElod(_IBL,float4(wReflect.xyz,iblSpecularMip)).rgb;
				half3 iblSpecularBRDF = EnvBRDF(_LUT,specularCol.rgb,roughness,NdotV);

				fixed4 finCol = 1.0f.xxxx;
				finCol.rgb = burleyDiffuse + specular * _LightColor0.rgb * atten + iblSpecularCol * iblSpecularBRDF * specularCol.rgb + iblDiffuseCol * diffuseCol.rgb;

				// finCol.rgb = (specular + lambertDiffuse + UNITY_LIGHTMODEL_AMBIENT.rgb) * _LightColor0 * atten + iblSpecularCol * iblSpecularBRDF * specularCol.rgb + iblDiffuseCol * diffuseCol.rgb

				// finCol.rgb = (specular + halfLambertDiffuse ) * _LightColor0 * atten + iblSpecularCol * iblSpecularBRDF * specularCol.rgb + iblDiffuseCol * diffuseCol.rgb
				finCol.rgb = GammaToLinearSpace(finCol.rgb);
				return finCol;
			}
			ENDCG
		}
	}
}
