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
Shader "Move/CharacterShader/Release_0.0.2"
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
		_NormalTex					("法线贴图", 2D) = "white" {}
///Mask
		[Space(5)][Header(Mask Properties)]
		[Space(10)]
		_MaskTex					("Mask贴图:金属(R)皮肤(G)粗糙度(B)",2D) = "white"{}
		[Space(10)]
		_SkinMaskValue				("Skin Mask Value",Range(0,1)) = 0.01
		_MetalMaskValue				("Metal Mask Value",Range(0,1)) = 0.55
		_SilkMaskValue				("Silk Mask Value",Range(0,1)) = 0.4
		//_OtherMaskValue				("Other Mask Value",Range(0,1)) = 0.1

		[Space(10)]
		_SkinRemapOMax				("Skin Remap OMax",Range(0,10)) = 1
		_MetalRemapOMax				("Metal Remap OMax",Range(0,10)) = 1
		_SilkRemapOMax				("Silk Remap OMax",Range(0,10)) = 1
		//_OtherRemapOMax			("Other Remap OMax",Range(0,10)) = 1
		
		[Space(10)]
		_Metallic					("金属度",Range(0,1)) = 1
		_OverrideMetallic			("覆盖原本的金属度的程度",Range(0,1)) = 0
		_Roughness					("粗糙度",Range(0,1)) = 1
		_OverrideRoughness			("覆盖原本的粗糙度的程度",Range(0,1)) = 0

		/*
		[Space(10)]
		_IsUseMetallicValue			("使用金属度偏移的程度",Range(0,1)) = 0
		_SkinMetallicIntensity		("Skin Metallic Intensity",Range(0,1)) = 1
		_MetalMetallicIntensity		("Metal Metallic Intensity",Range(0,1)) = 1
		_SilkMetallicIntensity		("Silk Metallic Intensity",Range(0,1)) = 1
		_OtherMetallicIntensity	("Other Metallic Intensity",Range(0,1)) = 1
		[Space(10)]
		_IsUseRoughnessValue		("使用粗糙度偏移的程度",Range(0,1)) = 0
		_SkinRoughnessIntensity		("Skin Roughness Intensity",Range(0,1)) = 1
		_MetalRoughnessIntensity	("Metal Roughness Intensity",Range(0,1)) = 1
		_SilkRoughnessIntensity		("Silk Roughness Intensity",Range(0,1)) = 1
		_OtherRoughnessIntensity	("Other Roughness Intensity",Range(0,1)) = 1
		*/

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
///MatCap
		[Space(5)][Header(MatCap Properties)]
		[Space(10)]
		_MatCapTexture				("MatCap贴图",2D) = "white"{}
		_MatCapIntensity			("MatCap 强度",Range(0,5)) = 1
		_MatCapControl				("MatCap 使用程度",Range(0,1)) = 0
		
		[Space(10)]
		_SkinMatCapIntensity		("Skin MatCap 强度",Range(0,1)) = 1
		_MetalMatCapIntensity		("Metal MatCap 强度",Range(0,1)) = 1
		_SilkMatCapIntensity		("Silk MatCap 强度",Range(0,1)) = 1
		_OtherMatCapIntensity		("Other MatCap 强度",Range(0,1)) = 1
///Rim
		[Space(5)][Header(Rim Properties)]
		[Space(10)]
		[Toggle]_IsUseAlbedoColor	("是否使用漫反射颜色值做为内发光颜色值",Float) = 1
		_RimColor					("内发光颜色",Color) = (1,1,1,1)
		_RimAttenuation				("内发光衰减",Range(0,10)) = 1
		_RimIntensity				("内发光强度",Range(0,1)) = 1		
///LightWrapping
		[Space(5)][Header(LightWrapping Properties)]
		[Space(10)]
		_LightWrappingColor			("Light Wrap 颜色",Color) = (1,1,1,1)
		_LightWrappingIntensity		("Light Wrap 强度",Range(0,1)) = 1

		_SkinLWAtten				("_SkinLWAtten",Range(0,5)) = 1
		_SkinLWInten				("_SkinLWInten",Range(0,50)) = 1
		_SkinLWRemapOMax			("SkinLWRemapOMax",Float) = 1
		[Space(3)]
		_SkinLightWrapIntensity		("Skin LightWrap 强度",Range(0,1)) = 1
		_MetalLightWrapIntensity	("Metal LightWrap 强度",Range(0,1)) = 1
		_SilkLightWrapIntensity		("Silk LightWrap 强度",Range(0,1)) = 1
		_OtherLightWrapIntensity	("Other LightWrap 强度",Range(0,1)) = 1
///Shadow		
		[Space(5)][Header(Shadow Properties)]
		[Space(10)]
		_IsUseShadowDeepend			("是否使用阴影加深",Range(0,1)) = 1
		_ShadowIntensity			("阴影加深的程度",Range(0,5)) = 2
///Light
		[Space(5)][Header(Light Properties)]
		[Space(10)]
		_LightIntensity				("灯光强度",Range(0,10)) = 0.001
		
		_SkinLightIntensity			("Skin  强度",Range(0,10)) = 1
		_MetalLightIntensity		("Metal  强度",Range(0,10)) = 1
		_SilkLightIntensity			("Silk  强度",Range(0,10)) = 1
		_OtherLightIntensity		("Other  强度",Range(0,10)) = 1

		_AmbientLightIntensity		("全局光照强度",Range(0,10)) = 1
///FillLight
		[Space(5)][Header(FillLight Properties)]
		[Space(10)]
		//_FillLightPos				("补光位置",Vector) = (1,1,1,1)
		_FillLightColor				("补光颜色",Color) = (1,1,1,1)
		_FillLightIntensity			("补光强度",Float) = 1
///Temp Variables
		
	}


	SubShader
	{
		Tags {  "Queue"="AlphaTest"
            "RenderType"="TransparentCutout" }
		LOD 100

		Pass
		{
			Tags {"LightMode" = "ForwardBase"  } 
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Move.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

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

			float  _MetalColValue;
		///Mask
			sampler2D _MaskTex;
			float4 _MaskTex_ST;

			float 	_SkinMaskValue	;
			float 	_MetalMaskValue	;
			float 	_SilkMaskValue	;
			float 	_OtherMaskValue	;

			float _Metallic;
			float _OverrideMetallic;
			float _Roughness;
			float _OverrideRoughness;
			
			float _SkinRemapOMax;
			float _MetalRemapOMax;
			float _SilkRemapOMax;
			float _OtherRemapOMax;

			/*
			float _IsUseMetallicValue;
			float _SkinMetallicIntensity	;
			float _MetalMetallicIntensity	;
			float _SilkMetallicIntensity	;
			float _OtherMetallicIntensity	;
			
			float _IsUseRoughnessValue;
			float _SkinRoughnessIntensity	;
			float _MetalRoughnessIntensity	;
			float _SilkRoughnessIntensity	;	
			float _OtherRoughnessIntensity;	
			*/
		///CubeMap
			samplerCUBE _EnvMap;
			float _ReflectionIntensity;

			float _SkinEnvIntensity;
			float _MetalEnvIntensity;
			float _SilkEnvIntensity;
			float _OtherEnvIntensity;
		///MatCap
			sampler2D _MatCapTexture;
			float4 _MatCapTexture_ST;
			float _MatCapIntensity;
			float _MatCapControl;

			float _SkinMatCapIntensity;
			float _MetalMatCapIntensity;
			float _SilkMatCapIntensity;
			float _OtherMatCapIntensity;

		///Rim
			float _IsUseAlbedoColor			;
			float4 _RimColor				;
			float _RimAttenuation			;
			float _RimIntensity				;

		///LightWrap
			float4 _LightWrappingColor		;
			float _LightWrappingIntensity	;
			
			float _SkinLWAtten;
			float _SkinLWInten;
			float  _SkinLWRemapOMax;
			
			float _SkinLightWrapIntensity	;	
			float _MetalLightWrapIntensity	;
			float _SilkLightWrapIntensity	;	
			float _OtherLightWrapIntensity;

		///Shadow
			float _IsUseShadowDeepend;
			float _ShadowIntensity;

		///Light
			float _LightIntensity;

			float _SkinLightIntensity		 ;
			float _MetalLightIntensity	 ;
			float _SilkLightIntensity		 ;
			float _OtherLightIntensity	 ;

			float _AmbientLightIntensity;
			
		///FillLight
			float4 _WorldSpaceLightPos1;
			float4 _FillLightPos;
			float4 _FillLightColor;
			float _FillLightIntensity;

		///Other
			float4 _LightColor0;

		///Temp
		
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
				//Gamma 矫正
				mainTex = pow(mainTex,2.2f);
				maskTex = pow(maskTex,2.2f);

			//Mask Variables
				//skin
				float skinMask = ceil(maskTex.g - _SkinMaskValue);//用于区分皮肤和其他材质，皮肤的部分是1，其他是0;
				_oMax = _SkinRemapOMax;
				float skinValue = (_oMin + ( (maskTex.g - _iMin) * (_oMax - _oMin) ) / (_iMax - _iMin)) * skinMask;
				
				//metal
				float metalMask = ceil(maskTex.r -_MetalMaskValue);
				_oMax = _MetalRemapOMax;
				float metalValue = (_oMin + ( (maskTex.r - _iMin) * (_oMax - _oMin) ) / (_iMax - _iMin)) * metalMask;

				//silk
				float silkMask = ceil(maskTex.r -_SilkMaskValue) * (1 - metalMask);
				_oMax = _SilkRemapOMax;
				float silkValue = (_oMin + ( (maskTex.r - _iMin) * (_oMax - _oMin) ) / (_iMax - _iMin)) * silkMask;

				//other
				float otherMask = (1-skinMask) * (1-metalMask) * (1-silkMask);
				_oMax = _OtherRemapOMax;
				float otherValue = otherMask;// * (_oMin + ( (maskTex.r - _iMin) * (_oMax - _oMin) ) / (_iMax - _iMin)) ;
			
				
			//Use Variables
				float3 albedoColor = (mainTex * _BaseColor).rgb;
				float metallic = lerp(maskTex.r,_Metallic,_OverrideMetallic);
				float roughness = lerp(maskTex.b,_Roughness,_OverrideRoughness);

				/*
				float skinMetallic		= metallic * _SkinMetallicIntensity		* skinMask;
				float metalMetallic		= metallic * _MetalMetallicIntensity	* metalMask;
				float silkMetallic		= metallic * _SilkMetallicIntensity		* silkMask;
				float otherMetallic	= metallic * _OtherMetallicIntensity	* otherMask;
				
				metallic = lerp(metallic,saturate(skinMetallic+metalMetallic+silkMetallic+otherMetallic),_IsUseMetallicValue);

				float skinRoughness		= roughness * _SkinRoughnessIntensity		* skinMask;
				float metalRoughness	= roughness * _MetalRoughnessIntensity		* metalMask;
				float silkRoughness		= roughness * _SilkRoughnessIntensity		* silkMask;
				float otherRoughness	= roughness * _OtherRoughnessIntensity	* otherMask;
				
				roughness = lerp(roughness,saturate(skinRoughness + metalRoughness + silkRoughness + otherRoughness),_IsUseRoughnessValue);
				*/

				float3 realAlbedo = albedoColor- albedoColor * metallic * (1 - metalMask*_MetalColValue);
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
			//Other
				float3 rimColor = lerp(_RimColor,realAlbedo,_IsUseAlbedoColor);
	///Alpha
				float Alpha = mainTex.a;
				clip(Alpha - 0.5);
	///Light
				float3 light1 = ComputeLight(realAlbedo,realSpecularColor,normalDir,roughness,lightPosition,lightColor,lightDir,viewDir);

				float lightIntensity = _LightIntensity;
				lightIntensity = 
					lightIntensity * _SkinLightIntensity * skinValue + 
					lightIntensity * _MetalLightIntensity * metalValue + 
					lightIntensity * _SilkLightIntensity * silkValue + 
					lightIntensity * _OtherLightIntensity * otherValue;
							
	///LightWrapping

	//			float3 lightWrapColor = LightWrapping_NdotL( albedoColor , _LightWrappingColor, _LightWrappingIntensity, roughness, normalDir,lightDir,viewDir, attenColor);
				float3 lightWrapColor = MyLightWrapping(maskTex.g,_LightWrappingColor,_SkinLWRemapOMax,_LightWrappingIntensity,normalDir,viewDir,_SkinLWAtten,_SkinLWInten);

				float3 skinLWCol		= lightWrapColor * _SkinLightWrapIntensity		* skinValue;
				float3 metalLWCol		= lightWrapColor * _MetalLightWrapIntensity		* metalValue;
				float3 silkLWCol		= lightWrapColor * _SilkLightWrapIntensity		* silkValue;
				float3 otherLWCol		= lightWrapColor * _OtherLightWrapIntensity		* otherValue;

				lightWrapColor =saturate( skinLWCol + metalLWCol + silkLWCol + otherLWCol);
	///FillLight
				float3 fillLightDir = normalize(_FillLightPos.xyz);
				float NdotFL = saturate(dot(normalDir,fillLightDir) * 0.5 +0.5);
				float3 fillLightColor = NdotFL * _FillLightColor * _FillLightIntensity * realAlbedo;
	///RimColor
				float3 rim = RimColor(rimColor,normalDir,viewDir,_RimAttenuation,_RimIntensity);
	///Shadow
				float shadowColor = lerp(1,pow(0.5 * dot(normalDir,lightDir)+0.5,_ShadowIntensity),_IsUseShadowDeepend);		
	///EnvCol
				float3 envColor = texCUBE(_EnvMap,reflectDir).rgb;
				envColor = pow(envColor.rgb,2.2f); 
				float3 envFresnel = Specular_F_Roughness(realSpecularColor,roughness * roughness,normalDir,viewDir);

				float3 skinEnvFresnel	= envFresnel * _SkinEnvIntensity	* skinValue;
				float3 metalEnvFresnel	= envFresnel * _MetalEnvIntensity	* metalValue;
				float3 silkEnvFresnel	= envFresnel * _SilkEnvIntensity	* silkValue;
				float3 otherEnvFresnel= envFresnel * _OtherEnvIntensity * otherValue;

				envFresnel = saturate( skinEnvFresnel +metalEnvFresnel + silkEnvFresnel + otherEnvFresnel);
	///MatCap
				float2 matCapUV = (mul (UNITY_MATRIX_V,float4(normalDir,0)).rgb * 0.5 + 0.5).rg;
				float matCapColor = dot(tex2D(_MatCapTexture,matCapUV),float3(0.3,0.59,0.11));
				matCapColor *= _MatCapIntensity;

				float skinMatCapCon		= _MatCapControl * _SkinMatCapIntensity		* skinValue;
				float metalMatCapCon	= _MatCapControl * _MetalMatCapIntensity	* metalValue;
				float silkMatCapCon		= _MatCapControl * _SilkMatCapIntensity		* silkValue;
				float otherMatCapCon	= _MatCapControl * _OtherMatCapIntensity	* otherValue;

				float matCapControl = saturate(skinMatCapCon + metalMatCapCon + silkMatCapCon + otherMatCapCon);
	///FinCol
				half3 finCol = attenuation * lightIntensity * light1;
				finCol += envColor * _ReflectionIntensity  * envFresnel;
				finCol += lightWrapColor;
				finCol += realAlbedo  * _AmbientLightIntensity * shadowColor;
				finCol += fillLightColor;
				finCol += rim;
				finCol *= lerp(1.0f.xxx,matCapColor,matCapControl);
				finCol = pow(finCol,1/2.2f);
				
				return half4(finCol,Alpha);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
