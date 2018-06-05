Shader "Move/BrushMetallic"
{   
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_SpecularShininess("Specular Shininess", Range(0.0, 50.0)) = 1.0
		_FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
		_AnisoOffset("_AnisoOffset",Range(-2,2)) = 0
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
				float4 tangent : TEXCOORD1 ;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
				float4 TtoW1 : TEXCOORD3;  
				float4 TtoW2 : TEXCOORD4;
			};

			float4 _Color;
			sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			float4 _SpecularColor;
			float _SpecularShininess;
			fixed _FresnelScale;

			float _AnisoOffset;
			v2f vert(appdata i)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(i.vertex);
				float4 worldPos =mul(unity_ObjectToWorld, i.vertex);
				o.posWorld = worldPos;
				o.normal = mul(float4(i.normal, 0.0), unity_WorldToObject).xyz;
				o.texcoord.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.texcoord.zw = i.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			 	fixed3 worldNormal = UnityObjectToWorldNormal(i.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w; 
                
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				float4 texColor = tex2D(_MainTex, i.texcoord.xy);
				float3 bump = UnpackNormal(tex2D(_BumpMap, i.texcoord.zw));
				// float3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				float3 worldNormal = normalize(float3(i.TtoW0.z,i.TtoW1.z,i.TtoW2.z));
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldViewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

				float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0.0, dot(worldNormal, worldLightDir));

				float3 specular;
				float3 reflectDirection = reflect(-worldViewDir, worldNormal);
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				
				float BP_Aniso = dot(normalize(worldNormal+bump), halfDir);
				BP_Aniso = max(0,sin(radians(180*(BP_Aniso+_AnisoOffset))));
				specular = _LightColor0.rgb * _SpecularColor.rgb * pow(BP_Aniso, _SpecularShininess);
 
			    //使用U3D 天空盒 UNITY_SAMPLE_TEXCUBE
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflectDirection);
				half3 skyColor = DecodeHDR(skyData,unity_SpecCube0_HDR);
				fixed3 reflection = skyColor.rgb;

				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
				fixed3 diffuseReflectionColor = lerp(diffuse, reflection, saturate(fresnel)); 
				fixed4 diffuseSpecularAmbient = fixed4(diffuseReflectionColor, 1.0) + fixed4(specular, 1.0) + UNITY_LIGHTMODEL_AMBIENT;

				fixed4 finCol = diffuseSpecularAmbient * texColor;

				//finCol.rgb = specular;
				return finCol;
			}

			ENDCG
		}
	}
}
