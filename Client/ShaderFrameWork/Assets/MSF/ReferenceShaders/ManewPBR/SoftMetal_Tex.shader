Shader "Move/SoftMetal_Tex"
{   
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("MainTex",2D) = "white" {}
		_BumpMap("BumpMap",2D) = "bump"{}
		_MetallicTex("MetallicTex",2D) = "white" {}
		_RoughnessTex("RoughnessTex", 2D) = "white" {}
		_NHxRoughness("_NHxRoughness",2D) = "white"{}
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
				float4 TtoW0 : TEXCOORD2;  
				float4 TtoW1 : TEXCOORD3;  
				float4 TtoW2 : TEXCOORD4;
				float4 ambient:TEXCOORD5;
			};

			
			float4 _Color;
			float4 _SpecularColor;
			sampler2D _MainTex,_BumpMap;
			sampler2D _MetallicTex,_RoughnessTex;
			sampler2D _NHxRoughness;

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.posWorld = mul(unity_ObjectToWorld, i.vertex);
				o.normal = mul(float4(i.normal, 0.0), unity_WorldToObject).xyz;
				o.texcoord = i.texcoord;

				fixed3 worldNormal = UnityObjectToWorldNormal(i.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w; 

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.posWorld.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.posWorld.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.posWorld.z);  

                o.ambient.rgb = Shade4PointLights (
	                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
	                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
	                unity_4LightAtten0, o.posWorld, worldNormal);

				o.ambient.rgb += UNITY_LIGHTMODEL_AMBIENT.rgb;

				return o;
			}

			inline float ClampDot(float3 v1,float3 v2)
			{
				return saturate(dot(v1,v2));
			}
		
			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 bump = UnpackNormal(tex2D(_BumpMap, i.texcoord));
				float3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
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

				float perceptualRoughness = tex2D(_RoughnessTex,i.texcoord).r;
				float roughness = perceptualRoughness*perceptualRoughness;
				float metallic = tex2D(_MetallicTex,i.texcoord).r;

				float3 mainTex = _Color.rgb * tex2D(_MainTex,i.texcoord).rgb;
				float3 albedo = mainTex*(1 - metallic);
				float3 spec = lerp(0.03,mainTex,metallic).rgb;

				

				// diffuse
				float FD90 = 0.5+2*perceptualRoughness*lh*lh;
				float3 rd = (1+(FD90-1)*pow(1-nl,5))*(1+(FD90-1)*pow(1-nv,5))* albedo / UNITY_PI;



				// specular
				float3 F = spec + (1 - spec) * pow(1 - lh, 5); // Schlick 
				
				float k = roughness * roughness * 0.5;
				float G = 1/( (nl*(1-k)+k) * (nv*(1-k)+k) +1e-5f);

				// float a = roughness * roughness;
				// float denominator = UNITY_PI*pow((a*a - 1)*(nh*nh)+1,2);
				// float D = a*a/denominator;

				float NHxRoughnessTex = tex2D( _NHxRoughness,float2(dot(worldNormal,worldHalfDir)*0.5+0.5,roughness)).r;
				float D = NHxRoughnessTex * NHxRoughnessTex;

				float3 rs = F * D * G / (4*nl*nv+1e-5f);



				float3 diffuseTerm = _LightColor0.rgb * rd * nl;
				float3 specularTerm = _LightColor0.rgb * saturate(rs) * nl;
				
				
				// UnitySky
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflectDirection);
				half3 skyColor = DecodeHDR(skyData,unity_SpecCube0_HDR);
				half surfaceReduction = 1.0 / (roughness*roughness + 1.0); 
				half3 grazingTerm = saturate(1-roughness + (1-spec));

				float3 indirectSpecular =  skyColor.rgb * lerp (spec, grazingTerm, pow (1 - nv,5)) * surfaceReduction;
				float3 indirectDiffuse = i.ambient.rgb * albedo;

				// fixed3 diffuseReflectionColor = lerp(diffuse, reflection, saturate(fresnel)); 
				// fixed4 diffuseSpecularAmbient = fixed4(diffuseReflectionColor, 1.0) + fixed4(specular*reflection, 1.0) + UNITY_LIGHTMODEL_AMBIENT;
				

				
				fixed4 finCol = fixed4(diffuseTerm + indirectDiffuse + specularTerm + indirectSpecular,1.0f);
				//finCol.rgb = indirectSpecular;
				return finCol;

				
			}

			ENDCG
		}
	}
}
