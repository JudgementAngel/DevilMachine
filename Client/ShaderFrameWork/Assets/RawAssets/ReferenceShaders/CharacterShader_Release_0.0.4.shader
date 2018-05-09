/*
	陈家豪
	20170801
	针对角色渲染的第一个整合版本
*/
/*
	整合要点：

	漫反射 = RGB+透贴
	法线  = 法线 + 
	Mask贴图 = 金属度  皮肤mask图  粗糙度
	MatCap = 
	cubeMap = 

	金属度 = 识别不同材质区域(金属 + 皮革 + 布料)
	金属 ：204 - 255 || 0.8 - 1
	丝绸 ：64 - 204  || 0.25 - 0.8
	其他 ：5 - 64	 || 0.02 - 0.25
	布料 和 皮肤 ：0 || 0 - 0.02

	皮肤mask图（区分布料和皮肤） = 非皮肤 0 - 10

	不同区域不同的
		LightWrapping值
		MatCap 强度值
		反射强度值

0.0.2
	Gamma矫正
*/
Shader "Move/CharacterShader/Release_0.0.4"
{
	Properties
	{
///Main
		[Space(0)][Header(Main Properties)]
		[Space(10)]
		_BaseColor					("漫反射颜色",Color) = (1,1,1,1)
		_MainTex					("漫反射贴图", 2D) = "white" {}
		_MetalColValue				("还原金属原本颜色的程度",Range(0,1)) = 1
		[Space(5)]
		_NormalTex					("法线贴图", 2D) = "bump" {}
///Mask
		[Space(5)][Header(Mask Properties)]
		[Space(10)]
		_MaskTex					("Mask贴图:金属(R)皮肤(G)粗糙度(B)",2D) = "white"{}
		
		
		[Space(10)]
		_Metallic					("金属度",Range(0,1)) = 1
		_OverrideMetallic			("覆盖原本的金属度的程度",Range(0,1)) = 0
		_Roughness					("粗糙度",Range(0,1)) = 1
		_OverrideRoughness			("覆盖原本的粗糙度的程度",Range(0,1)) = 0



///CubeMap
		[Space(5)][Header(CubeMap Properties)]
		[Space(10)]
		_EnvMap						("环境贴图",Cube) = "_Skybox" {}
		_ReflectionIntensity		("环境贴图的强度",Range(0,10)) = 1

		[Space(10)]
		_SkinEnvIntensity			("Skin 环境光强度",Range(0,1)) = 1
		_MetalEnvIntensity			("Metal 环境光强度",Range(0,1)) = 1
		_SilkEnvIntensity			("Silk 环境光强度",Range(0,1)) = 1
		_OtherEnvIntensity		("Other 环境光强度",Range(0,1)) = 1

		



///Light
		[Space(5)][Header(Light Properties)]
		[Space(10)]
		_LightIntensity				("灯光强度",Range(0,10)) = 0.001
		


		_AmbientLightIntensity		("全局光照强度",Range(0,10)) = 1

		
	}


	SubShader
	{
		Tags {  //"Queue"="AlphaTest"
            "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags {"LightMode" = "ForwardBase"  } 
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//#include "Move.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			#define PI            3.14159265359f
			#define TWO_PI        6.28318530718f
			#define FOUR_PI       12.56637061436f
			#define INV_PI        0.31830988618f
			#define INV_TWO_PI    0.15915494309f
			#define INV_FOUR_PI   0.07957747155f
			#define HALF_PI       1.57079632679f
			#define INV_HALF_PI   0.636619772367f

///Structure
			struct appdata 
			{
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 Normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 wPos : TEXCOORD1;
				float3x3 tangentToWorld : TEXCOORD2;
				LIGHTING_COORDS(3,4)
			};

///Variables
		///Main
			float4 _BaseColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _NormalTex;
			float4 _NormalTex_ST;


		///Mask
			sampler2D _MaskTex;
			float4 _MaskTex_ST;

		
			float _Metallic;
			float _OverrideMetallic;
			float _Roughness;
			float _OverrideRoughness;
			
	

		///CubeMap
			samplerCUBE _EnvMap;
			float _ReflectionIntensity;


		///Light
			float _LightIntensity;

		

			float _AmbientLightIntensity;
			
	

		///Other
			float4 _LightColor0;

		///Temp
		




float3 Specular_F_Roughness(float3 specularColor,float a ,float3 h,float3 v)
{
	// Sclick using roughness to attenuate fresnel.
	return (specularColor + (max(1.0f-a, specularColor) - specularColor) * pow((1 - saturate(dot(v, h))), 5));
}

//----------------------------------------------------------------
			
float Specular_D(float a, float NdH)
{
	//NormalDistribution_GGX
	float a2 = a*a;
	float NdH2 = NdH * NdH;

	float denominator = NdH2 * (a2 - 1.0f) + 1.0f;
	denominator *= denominator;
	denominator *= PI;

	return a2 / denominator;
}
float3 Specular_F(float3 specularColor, float3 h, float3 v)
{
	return (specularColor + (1.0f - specularColor) * pow((1.0f - saturate(dot(v, h))), 5));
}
float Specular_G(float a, float NdV, float NdL, float NdH, float VdH, float LdV)
{
		// Smith schlick-GGX.
	float k = a * 0.5f;
	float GV = NdV / (NdV * (1 - k) + k);
	float GL = NdL / (NdL * (1 - k) + k);

	return GV * GL;
}

float3 Specular(float3 specularColor, float3 h, float3 v, float3 l, float a, float NdL, float NdV, float NdH, float VdH, float LdV)
{
	return ((Specular_D(a, NdH) * Specular_G(a, NdV, NdL, NdH, VdH, LdV)) * Specular_F(specularColor, v, h) ) / (4.0f * NdL * NdV + 0.0001f);
}
			
float3 Diffuse(float3 pAlbedo)//Lambert光照模型
{
	return pAlbedo/PI;
}



float3 ComputeLight(float3 albedoColor,float3 specularColor, float3 normal, float roughness, float3 lightPosition, float3 lightColor, float3 lightDir, float3 viewDir)
{
	// Compute some useful values.
	float NdL = saturate(dot(normal, lightDir));
	float NdV = saturate(dot(normal, viewDir));
	float3 h = normalize(lightDir + viewDir);
	float NdH = saturate(dot(normal, h));
	float VdH = saturate(dot(viewDir, h));
	float LdV = saturate(dot(lightDir, viewDir));
	float a = max(0.001f, roughness * roughness);

	float3 cDiff = Diffuse(albedoColor);
	float3 cSpec = Specular(specularColor, h, viewDir, lightDir, a, NdL, NdV, NdH, VdH, LdV);

	return lightColor * NdL * (cDiff * (1.0f - cSpec) + cSpec);
}



///Vertex Function
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				o.Normal = v.normal;
				o.wPos = mul(unity_ObjectToWorld, v.vertex);

				float3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                float3 tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                float3 bitangentDir = normalize(cross(normalDir, tangentDir) * v.tangent.w); 
				
				o.tangentToWorld[0] = tangentDir;
				o.tangentToWorld[1] = bitangentDir;
				o.tangentToWorld[2] = normalDir;

				return o;
			}

///Fragment Function			
			half4 frag (v2f i) : SV_Target
			{

	///Initialize Some Variables
			//Other
				///(_oMin + ( (_Val - _iMin) * (_oMax - _oMin) ) / (_iMax - _iMin))
				float _iMin = 0;float _iMax = 1;
				float _oMin = 0;float _oMax = 1;
			//Lighting
				float attenuation = LIGHT_ATTENUATION(i);
				float3 lightPosition = _WorldSpaceLightPos0.xyz;
				float3 lightColor = _LightColor0.rgb;
				float3 attenColor = attenuation * _LightColor0.rgb;
			//Texture
				float4 mainTex = tex2D(_MainTex,TRANSFORM_TEX(i.uv,_MainTex));
				float4 normalTex = tex2D(_NormalTex,TRANSFORM_TEX(i.uv,_NormalTex));
				float4 maskTex = tex2D(_MaskTex,TRANSFORM_TEX(i.uv,_MaskTex));
			
			
				
			//Use Variables
				float3 albedoColor = (mainTex * _BaseColor).rgb;
				float metallic = lerp(maskTex.r,_Metallic,_OverrideMetallic);
				float roughness = lerp(maskTex.b,_Roughness,_OverrideRoughness);

			
				float3 realAlbedo = albedoColor- albedoColor * metallic ;
				float3 realSpecularColor = lerp(0.03f, albedoColor, metallic);//对于电介质使用默认的0.03f
			
			//Vector				
				float3x3 tangentTransform = float3x3(i.tangentToWorld[0],i.tangentToWorld[1],i.tangentToWorld[2]);
				float3 normalTangent = UnpackNormal(normalTex);
			
				float3 normalDir = normalize(mul(normalTangent,tangentTransform));
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos.xyz);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 halfDir = normalize(viewDir + lightDir);
				float3 reflectDir = reflect(-viewDir,normalDir);

				float NdotV = abs(dot( normalDir, viewDir ));
                float NdotH = saturate(dot( normalDir, halfDir ));
                float VdotH = saturate(dot( viewDir, halfDir ));
				float LdotH = saturate(dot(lightDir, halfDir));
				float NdotL = max(0.0,dot( normalDir, lightDir ));
		
				
	///Alpha
				float Alpha = mainTex.a;

	///Light
				float3 light1 = ComputeLight(realAlbedo,realSpecularColor,normalDir,roughness,lightPosition,lightColor,lightDir,viewDir);
		
				float lightIntensity = _LightIntensity;
			


		

	///EnvCol
				float3 envColor = texCUBE(_EnvMap,reflectDir).rgb;
				envColor = pow(envColor.rgb,2.2f); 
				float3 envFresnel = Specular_F_Roughness(realSpecularColor,roughness * roughness,normalDir,viewDir);


			
	///FinCol
				half3 finCol = 0.0f.xxx;

				finCol += attenuation * lightIntensity * light1;
				finCol += envColor * _ReflectionIntensity  * envFresnel;
				
				finCol += realAlbedo  * _AmbientLightIntensity;// * shadowColor;
				
				
				
				
				return half4(finCol,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
