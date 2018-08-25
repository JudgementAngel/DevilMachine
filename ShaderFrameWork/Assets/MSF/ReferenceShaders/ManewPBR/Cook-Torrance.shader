Shader "Move/PBR_Cook-Torrance"
{   
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_Metallic("_Metallic",Range(0,1)) = 1
		_Roughness("_Roughness", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
			};

			
			float4 _Color;
			float4 _SpecularColor;
			fixed _Metallic,_Roughness;
		
			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.posWorld = mul(unity_ObjectToWorld, i.vertex);
				o.normal = mul(float4(i.normal, 0.0), unity_WorldToObject).xyz;
				o.texcoord = i.texcoord;
				return o;
			}

			inline float ClampDot(float3 v1,float3 v2)
			{
				return saturate(dot(v1,v2));
			}
		
			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 worldNormal = normalize(i.normal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldViewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

				

				
				float3 reflectDirection = reflect(-worldViewDir, worldNormal);
				fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);

			    //specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _SpecularShininess);

			    

				float nh = ClampDot(worldNormal,worldHalfDir);
				float nv = ClampDot(worldNormal,worldViewDir);
				float vh = ClampDot(worldViewDir,worldHalfDir);
				float lh = ClampDot(worldLightDir,worldHalfDir);
				float nl = ClampDot(worldNormal,worldLightDir);

				
				float3 albedo = _Color.rgb*(1 - _Metallic);
				float3 spec = lerp(0.03,_Color,_Metallic).rgb;

				float3 F = spec + (1 - spec) * pow(1 - vh, 5); // Schlick 
				
				float Gb = 2*nh*nv / vh;
				float Gc = 2*nh*nl / lh;
				float G = min(1,min(Gb,Gc));

				float m = _Roughness;
				float d1 = (nh*nh-1)/(m*m*nh*nh);
				float d2 = UNITY_PI*m*m*pow(nh,4);
				float D = (1/d2)*exp(d1);

				float3 rs = F * D * G / (4*nl*nv+1e-5f);

				float3 diffuseTerm = _LightColor0.rgb * albedo * nl;
				float3 specularTerm = _LightColor0.rgb * saturate(rs) * nl;
				
				
				// UnitySky
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflectDirection);
				half3 skyColor = DecodeHDR(skyData,unity_SpecCube0_HDR);
				half surfaceReduction = 1.0 / (_Roughness*_Roughness + 1.0); 
				half3 grazingTerm = saturate(1-_Roughness + (1-spec));

				float3 indirectSpecular =  skyColor.rgb * lerp (spec, grazingTerm, pow (1 - nv,5)) * surfaceReduction;
				float3 indirectDiffuse = UNITY_LIGHTMODEL_AMBIENT * albedo;

				// fixed3 diffuseReflectionColor = lerp(diffuse, reflection, saturate(fresnel)); 
				// fixed4 diffuseSpecularAmbient = fixed4(diffuseReflectionColor, 1.0) + fixed4(specular*reflection, 1.0) + UNITY_LIGHTMODEL_AMBIENT;
				

				
				fixed4 finCol = fixed4(diffuseTerm + indirectDiffuse + specularTerm + indirectSpecular,1.0f);
				//finCol.rgb = reflection;
				return finCol;

				
			}

			ENDCG
		}
	}
}
