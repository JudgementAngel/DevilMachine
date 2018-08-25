Shader "Move/PBR_Ward"
{   
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_Metallic("metallic",Range(0,1)) = 1
		_Roughness("roughness", Range(0, 1)) = 1
		_AlphaX("_AlphaX",Range(-3,3)) = 1
		_AlphaY("_AlphaY",Range(-3,3)) = 1
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
				float4 tangent:TANGENT;
			};

			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 tangent:TANGENT;
			};

			
			float4 _Color;
			float4 _SpecularColor;
			float _Metallic,_Roughness;
			float _AlphaX,_AlphaY;
			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.posWorld = mul(unity_ObjectToWorld, i.vertex);
				o.normal = mul(float4(i.normal, 0.0), unity_WorldToObject).xyz;
				o.texcoord = i.texcoord;
				o.tangent = UnityObjectToWorldDir( i.tangent.xyz/i.tangent.w);
				
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
				float3 worldTangent = normalize(i.tangent);
				fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);
				float3 worldBinormal = normalize(cross(worldNormal,worldTangent));
				
				float3 reflectDirection = reflect(-worldViewDir, worldNormal);

			    //specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _SpecularShininess);

				float nh = ClampDot(worldNormal,worldHalfDir);
				float nv = ClampDot(worldNormal,worldViewDir);
				float vh = ClampDot(worldViewDir,worldHalfDir);
				float lh = ClampDot(worldLightDir,worldHalfDir);
				float nl = ClampDot(worldNormal,worldLightDir);
				float ht = dot(worldHalfDir,worldTangent);
				float hb = dot(worldHalfDir,worldBinormal);

				float perceptualRoughness = _Roughness;
				float roughness = _Roughness*_Roughness;
				float metallic = _Metallic;

				float3 albedo = _Color.rgb*(1 - metallic);
				float3 spec = lerp(0.03,_Color,metallic).rgb;

				

				// diffuse
				float FD90 = 0.5+2*perceptualRoughness*lh*lh;
				float3 rd = (1+(FD90-1)*pow(1-nl,5))*(1+(FD90-1)*pow(1-nv,5))* albedo / UNITY_PI;



				// specular
				

				// float3 rs = exp(-2 * (pow(ht/ax,2) + pow(hb/ay,2) ) / (1+nh+1e-5f) ) * (1 / (sqrt(nl*nv)+ 1e-5f ) );
				// float3 specularTerm = _LightColor0.rgb * saturate(rs) * nl;
				float ax = _AlphaX; float ay = _AlphaY;
				float3 rs = exp(-2 * ( pow(ht/ax,2) + pow(hb/ay,2) ) / (1+nh+1e-5f) ) * sqrt(max(0,nl/(nv+1e-5f)));
				float3 specularTerm = _LightColor0.rgb * saturate(rs) ;

				float3 diffuseTerm = _LightColor0.rgb * rd * nl;
				
				// UnitySky
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflectDirection);
				half3 skyColor = DecodeHDR(skyData,unity_SpecCube0_HDR);
				half surfaceReduction = 1.0 / (roughness*roughness + 1.0); 
				half3 grazingTerm = saturate(1-roughness + (1-spec));

				float3 indirectSpecular =  skyColor.rgb * lerp (spec, grazingTerm, pow (1 - nv,5)) * surfaceReduction;
				float3 indirectDiffuse = UNITY_LIGHTMODEL_AMBIENT * albedo;

				// fixed3 diffuseReflectionColor = lerp(diffuse, reflection, saturate(fresnel)); 
				// fixed4 diffuseSpecularAmbient = fixed4(diffuseReflectionColor, 1.0) + fixed4(specular*reflection, 1.0) + UNITY_LIGHTMODEL_AMBIENT;
				

				
				fixed4 finCol = fixed4(diffuseTerm + indirectDiffuse + specularTerm + indirectSpecular,1.0f);
				//finCol.rgb = sqrt(max(0,nl/(nv+1e-5f) )) *exp(-2 * ( pow(ht/(ax+1e-5f),2) + pow(hb/(ay+1e-5f),2) )/ (1+nh+1e-5f) )  ;//indirectSpecular;
				return finCol;

				
			}

			ENDCG
		}
	}
}
