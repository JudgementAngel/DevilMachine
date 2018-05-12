/*
	陈家豪
	20170809
	头发
*/

Shader "Move/CharacterShader/Hair_0.0.4"
{
	Properties
	{
///Main
		[Space(0)][Header(Main Properties)]
		[Space(10)]
		//_BaseColor					("漫反射颜色",Color) = (1,1,1,1)
		_MainTex					("漫反射贴图", 2D) = "white" {}
		//_MetalColValue				("还原金属原本颜色的程度",Range(0,1)) = 1
		[Space(5)]
		_NormalTex					("法线贴图", 2D) = "bump" {}
		
///HairSpecular
		[Space(0)][Header(HairSpecular Properties)]
		[Space(10)]
		//_SpecularShiftTex			("SpecularShiftTex",2D) = "white"{}
		//_SpecularSmooth				("SpecularSmooth",Range(0,100)) = 1
		//_HairIntensity				("Hair Intensity",Float) =1
		_SpecularColorPow			("高光强弱系数",Range(0,2)) = 0.5

		_HairPow1					("高光1范围",Range(0,1)) = 1
		_HairPow2					("高光2范围",Range(0,1)) = 1
		
		_SpecularColor1				("高光1颜色",Color) = (1,1,1,1) 
		_SpecularColor2				("高光2颜色",Color) = (1,1,1,1) 
		//_Shift						("Shift",Range(-1,1)) =0.5 
		//_PrimaryShift				("Primary Shift",Float) = 0
		//_SecondaryShift				("Secondary Shift",Float) = 0
		_IsUseNormalTex				("是否使用法线贴图",Range(0,1)) = 1
		_HairShift1					("_HairShift1",Range(-2,2)) = 0
		_HairShift2					("_HairShift2",Range(-2,2)) = 0
		/*
		_GroundColor				("地面光照颜色（只用于参考）",Color) = (0.6093,0.8320,0.5742,1)
		_GroundAmbco				("地面光照影响率（只用于参考）",Range(0,1)) = 1
		_SkyColor					("天光颜色（只用于参考）",Color) = (0.5703,0.7539,0.8359,1)
		_SkyAmbco					("天光影响率（只用于参考）",Range(0,1)) = 1
		*/
		_HairColor					("头发颜色",Color) = (0.2,0.2,0.2,1.0)
		_LUTTex 					("LUT_TEX",2D) = "white"{}

///MatCap
		[Space(5)][Header(MatCap Properties)]
		[Space(10)]
		_MatCapColor				("MatCap Color",Color) = (1,1,1,1)
		_MatCapTexture				("MatCap贴图",2D) = "white"{}
		_MatCapIntensity			("MatCap 强度",Range(0,5)) = 1
		_MatCapControl				("MatCap 使用程度",Range(0,1)) = 0
		//_MatCapNormalTex			("MatCap Normal Tex",2D) = "bump"{}
		_MatCapUseNormal			("MatCap Use Normal",Range(0,1)) = 0.2
		_MatCapOffset				("MatCap Offset",Vector) = (1,1,1,1)

///Rim
		[Space(5)][Header(Rim Properties)]
		[Space(10)]
		[Toggle]_IsUseAlbedoColor	("是否使用漫反射颜色值做为内发光颜色值",Float) = 1
		_RimColor					("内发光颜色",Color) = (1,1,1,1)
		_RimAttenuation				("内发光衰减",Range(0,10)) = 1
		_RimIntensity				("内发光强度",Range(0,1)) = 1		

///FillLight
		[Space(5)][Header(FillLight Properties)]
		[Space(10)]
		//_FillLightPos				("补光位置",Vector) = (1,1,1,1)
		_FillLightColor				("补光颜色",Color) = (1,1,1,1)
		_FillLightIntensity			("补光强度",Float) = 1
/*		
		///Light
				[Space(5)][Header(Light Properties)]
				[Space(10)]
				_LightIntensity				("灯光强度",Range(0,10)) = 0.001
				_AmbientLightIntensity		("全局光照强度",Range(0,10)) = 1
		
		///Temp Variables
				_TempValue					("TempValue",Range(0,1)) = 1
				_TempValue1					("TempValue",Range(-1,1)) = 1
				_TempValue2					("TempValue",Range(0,1)) = 1
				_TempValue3					("TempValue",Vector) = (1,1,1,1)
*/
	}


	SubShader
	{
		Tags {  "Queue"="Transparent"
            "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Tags {"LightMode" = "ForwardBase"  "Queue"="AlphaTest"} 
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite On
			//cull off
			//ZTest less
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag1
			
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
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 wPos : TEXCOORD1;
				float3x3 tangentToWorld : TEXCOORD2;
				LIGHTING_COORDS(3,4)
			};

///Variables
		///Main
			float4		_BaseColor			;
			sampler2D	_MainTex			;
			float4		_MainTex_ST			;
			
			sampler2D	_NormalTex			;
			float4		_NormalTex_ST		;


		///HairSpecular
		    sampler2D	_SpecularShiftTex			;		
			float4		_SpecularShiftTex_ST		;
			float		_SpecularSmooth		;
			float		_HairIntensity;
			float  		_SpecularColorPow;
			float		_HairPow1;
			float		_HairPow2;
			float		_Shift;
			float		_PrimaryShift;
			float		_SecondaryShift;
			float4		_SpecularColor1;
			float4		_SpecularColor2;
			float 		_HairShift1;
			float 		_HairShift2;

			/*
			float4      _GroundColor;
			float 		_GroundAmbco;

			float4      _SkyColor;
			float 		_SkyAmbco;
			*/

			float4 		_HairColor;
			sampler2D _LUTTex;
			float4 _LUTTex_ST;

			float _IsUseNormalTex;

			float4 _LightColor0;

		///Rim
			float _IsUseAlbedoColor			;
			float4 _RimColor				;
			float _RimAttenuation			;
			float _RimIntensity				;

		///MatCap
			sampler2D _MatCapTexture;
			float4 _MatCapTexture_ST;
			float _MatCapIntensity;
			float _MatCapControl;
			float4 _MatCapColor;

			sampler2D _MatCapNormalTex;
			float4 _MatCapNormalTex_ST;

			float _MatCapUseNormal;
			float4 _MatCapOffset;
		///FillLight
			float4 _WorldSpaceLightPos1;
			float4 _FillLightPos;
			float4 _FillLightColor;
			float _FillLightIntensity;
/*
		///Light
			float		_LightIntensity		;
			float _AmbientLightIntensity	;
			
		

		///Other
			float4 _LightColor0;

		///Temp
			float _TempValue;
			float _TempValue1;
			float _TempValue2;
			float4 _TempValue3;
*/
///Other Function 
			float3 ShiftTangent(float3 T,float3 N,float shift)
			{
				return T + N * shift;
			}

			float StrandSpecularTex(sampler2D LUTSampler,float3 T,float3 H, float3 V, float3 L, float fExp)
			{
				float  fDotTH = dot(T, H)*0.5+0.5;
				float2 LUTTexCoord = float2(fDotTH,fExp);
				float  fLUT = tex2D(LUTSampler, LUTTexCoord).x;
				float  fDirAtten = smoothstep(-1.0f, 0.0f, dot(V, L));
				return fDirAtten * fLUT;
			}
/*
			float StrandSpecular(float3 T, float3 V, float3 L, float fExp)
			{
				float3 H = normalize(L + V);
				float fDotTH = dot(T, H);
				float fSinTH = sqrt(1.0f - fDotTH * fDotTH);
				float fDirAtten = smoothstep(-1.0f, 0.0f, dot(V, L));
				return fDirAtten * pow(fSinTH, fExp);
			}

			float3 HairLighting(float3 tangent,float3 normal,float3 lightVec,float3 viewVec,float2 uv,float3 diffuseColor,float3 specularColor1,float3 specularColor2,float specExp1,float specExp2)
			{
				//shift  tangent
				float shiftTex = tex2D(_SpecularShiftTex,uv) - 0.5;
				float3 t1 = ShiftTangent(tangent,normal,_PrimaryShift + shiftTex);
				float3 t2 = ShiftTangent(tangent,normal,_SecondaryShift + shiftTex);

				//diffuse lighting:the lerp shifts the shadow boundary for a softer look
				float3 diffuse = saturate(lerp(0.25,1.0,dot(normal,lightVec)));
				diffuse *= diffuseColor;

				//specular lighting
				float3 specular = specularColor1 * StrandSpecular (t1,viewVec,lightVec,specExp1);

				//add second specular term,modulated with noise texture
				float specMask = 1;//tex2D(tSpecMask,uv);//approximate sparkles using texture
				specular += specularColor2 * specMask * StrandSpecular (t2,viewVec,lightVec,specExp2);

				//final color assembly 
				float3 o;
				o.rgb = (diffuse + specular) * tex2D (_MainTex,uv) * _LightColor0.rgb;
				//o.rgb *= ambOcc;
				
				return o;
			}
*/			
///Vertex Function
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				
				o.wPos = mul(unity_ObjectToWorld, v.vertex);

				float3 normalDir = UnityObjectToWorldNormal(v.normal);
                float3 tangentDir =  mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz ;
                float3 binormalDir = cross(v.normal, v.tangent.xyz) * v.tangent.w; 
                binormalDir = mul((float3x3)unity_ObjectToWorld,binormalDir);
				
				o.tangentToWorld[0] = tangentDir;
				o.tangentToWorld[1] = binormalDir;
				o.tangentToWorld[2] = normalDir;

				o.worldNormal = normalDir;
				return o;
			}

///Fragment Function	

			half4 frag1(v2f i):SV_Target
			{

				//	Specular texture channels:
				//	.r: specular scale
				//	.g: specular noise
				//	.b: specular shift
				float4 colBaseTex = tex2D(_MainTex,TRANSFORM_TEX(i.uv,_MainTex));
				float4 normalTex = tex2D(_NormalTex,TRANSFORM_TEX(i.uv,_NormalTex));
				
				//clip(colBaseTex.a -0.8f);



				//float4 colSpecTex = tex2D(_SpecularShiftTex,TRANSFORM_TEX(i.uv,_SpecularShiftTex));
				//colSpecTex = pow(colSpecTex,2.2f);
				float3 normalTangent = UnpackNormal(normalTex);
				
				float3 vNormalWorld = normalize(mul(normalTangent,i.tangentToWorld));
				
				float3 vNormal = lerp(i.tangentToWorld[2],vNormalWorld,_IsUseNormalTex);
				
				float3 vTangent = i.tangentToWorld[0];
				
				//float fBaseShift = colSpecTex.b - 0.5f;
				float fBaseShift = 0.5f;

				float3 t1 = ShiftTangent(vTangent, vNormal, fBaseShift + _HairShift1*10);
				float3 t2 = ShiftTangent(vTangent, vNormal, fBaseShift + _HairShift2*10);

				//	Diffuse lighting
				float3 vViewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos.xyz);
				float3 vLightDir = normalize(_WorldSpaceLightPos0.xyz);

				float fDotNL = dot(vNormal,vLightDir);
				//sky light and ground light
				float3 colDiffuse = fDotNL * 0.5f +0.5f;
				
				//float fAmbientCo = saturate(fDotNL + 1);
				//float4 vAmbient = lerp(_GroundColor*_GroundAmbco,_SkyColor*_SkyAmbco,fAmbientCo);
				//colDiffuse = lerp(vAmbient,1.0f,colDiffuse) * _HairColor.rgb;
				colDiffuse *= _HairColor.rgb; 
				//	Specular lighting
				float3 H = normalize(vLightDir + vViewDir);
				float3 colSpecular1 = 0.0f.xxx;
				float3 colSpecular2 = 0.0f.xxx;
				colSpecular1 = _SpecularColor1.rgb * StrandSpecularTex(_LUTTex,t1,H,vViewDir,vLightDir,_HairPow1);
				colSpecular2 = _SpecularColor2.rgb * StrandSpecularTex(_LUTTex,t2,H,vViewDir,vLightDir,_HairPow2);

				///MatCap
				//float3 matCapNormal = UnpackNormal(tex2D(_MatCapNormalTex,TRANSFORM_TEX(i.uv,_MatCapNormalTex))) ;
				float3 matCapNormal = lerp(i.tangentToWorld[2],vNormalWorld,_MatCapUseNormal);
				float3 matTangent = cross(i.tangentToWorld[2],i.tangentToWorld[1] + normalize(_MatCapOffset).rgb);
				float2 matCapUV = (mul (UNITY_MATRIX_V,float4(matCapNormal,0)).rgb * 0.5 + 0.5).rg;
				float matCapColor = dot(tex2D(_MatCapTexture,matCapUV),float3(0.3,0.59,0.11));
				matCapColor *= _MatCapIntensity * _MatCapColor;
				//matCapColor = pow(matCapColor,2.0f);

				///RimColor
				float3 rimColor = lerp(_RimColor,colBaseTex.rgb,_IsUseAlbedoColor);
				float3 rim = RimColor(rimColor,vNormal,vViewDir,_RimAttenuation,_RimIntensity);

				//FillLight
				float3 fillLightDir = normalize(_FillLightPos.xyz);
				float NdotFL = saturate(dot(vNormal,fillLightDir) * 0.5 +0.5);
				float3 fillLightColor = NdotFL * _FillLightColor * _FillLightIntensity * colBaseTex.xyz;

				//	Add some noise to specular 2
				//float3 colSpecular = (colSpecular1 + colSpecular2 * colSpecTex.g) * colSpecTex.r;// * _LightColor0.rgb;
				float3 colSpecular = colSpecular1 + colSpecular2;
				float3 finCol = 0.0f.xxx;
				finCol += fillLightColor;
				finCol += rim;
				finCol +=(colDiffuse + colSpecular * _SpecularColorPow);// * colBaseTex.rgb;
				finCol += lerp(0.0f.xxx,matCapColor,_MatCapControl);
				
				//colOut = pow(colOut,1/2.2f);
				return half4(finCol,colBaseTex.a);
			}

/*
			
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
				float4 offsetTex = tex2D(_SpecularShiftTex,TRANSFORM_TEX(i.uv,_SpecularShiftTex));

				//Gamma 矫正
				//mainTex = pow(mainTex,2.2f);
				//offsetTex = pow(offsetTex,2.2f);

			//Use Variables
				float3 albedoColor = (mainTex * _BaseColor).rgb;

				float3 realAlbedo = albedoColor;
				float3 realSpecularColor = lerp(0.03f, albedoColor, 0);//对于电介质使用默认的0.03f
			
			//Vector			
				float3 vTangent = i.tangentToWorld[0];

				float3x3 tangentTransform = float3x3(i.tangentToWorld[0],i.tangentToWorld[1],i.tangentToWorld[2]);
				float3 normalTangent = UnpackNormal(normalTex);
			
				float3 normalDir = normalize(mul(normalTangent,tangentTransform));
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos.xyz);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 halfDir = normalize(viewDir + lightDir);
				float3 reflectDir = reflect(-viewDir,normalDir);

				tangentTransform = float3x3(i.tangentToWorld[0],i.tangentToWorld[1],normalTangent);

				float3 tangentDir = i.tangentToWorld[0];//normalize(cross(i.bitangentDir,normalDir)) ;//normalize(i.tangentToWorld[0]);//normalize(mul(i.tangentToWorld[0],tangentTransform));
			
				tangentDir = lerp( tangentDir,i.tangentToWorld[1],_TempValue);
				
				float NdotV = dot( normalDir, viewDir );
                float NdotH = saturate(dot( normalDir, halfDir ));
                float VdotH = saturate(dot( viewDir, halfDir ));
				float LdotH = saturate(dot(lightDir, halfDir));
				float NdotL = max(0.0,dot( normalDir, lightDir ));

			//Shift
				float fBaseShift = tex2D(_SpecularShiftTex,TRANSFORM_TEX(i.uv,_SpecularShiftTex)).b - 0.5f;
				float t1 = ShiftTangent(vTangent,normalDir,fBaseShift + _HairShift1);
				float t2 = ShiftTangent(vTangent,normalDir,fBaseShift + _HairShift2);

			//Alpha
				float Alpha = mainTex.a;

			//FillLight
				float3 fillLightDir = normalize(_FillLightPos.xyz);
				float NdotFL = saturate(dot(normalDir,fillLightDir) * 0.5 +0.5);
				float3 fillLightColor = NdotFL * _FillLightColor * _FillLightIntensity * realAlbedo;
			///HairSpecular
				
			
				float shift = offsetTex.r + NdotV*_Shift;
				tangentDir -= normalDir * shift;
				
				float3 myHairSpecular = StrandSpecular(tangentDir,-viewDir+_TempValue3.xyz,lightDir,_SpecularSmooth);
				float3 myHairSpecular1 = saturate(StrandSpecular(tangentDir + tangentDir*(shift+_TempValue1) ,-viewDir,lightDir,_SpecularSmooth)) * _LightColor0;
				myHairSpecular =  HairLighting( tangentDir, normalDir, lightDir, viewDir,i.uv, realAlbedo, _SpecularColor1.rgb, _SpecularColor2.rgb,_P1, _P2);
				myHairSpecular += lerp(0,(myHairSpecular1/2)*realAlbedo,_TempValue2);

				float3 viewNormal = mul (UNITY_MATRIX_V,float4(abs(normalDir),0)).rgb * 0.5 + 0.5;
				viewNormal = 1- viewNormal;
				viewNormal = saturate(pow(dot(viewNormal,float3(0.3,0.59,0.11)) ,5) * 5);
				
				myHairSpecular += viewNormal;

			///MatCap
				float2 matCapUV = (mul (UNITY_MATRIX_V,float4(normalDir,0)).rgb * 0.5 + 0.5).rg;
				float matCapColor = dot(tex2D(_MatCapTexture,matCapUV),float3(0.3,0.59,0.11));
				matCapColor *= _MatCapIntensity * _MatCapColor;
				matCapColor = pow(matCapColor,2.0f);
			///FinCol
				half3 finCol = realAlbedo  * _AmbientLightIntensity;
				finCol += fillLightColor;
				//finCol += saturate(myHairSpecular * _HairIntensity);
				finCol *= lerp(1.0f.xxx,matCapColor,_MatCapControl);
				//Gamma矫正;
				//finCol = pow(finCol,1/2.2f);

				return half4(finCol,Alpha);
			}
*/			


			ENDCG
		}




	}
}
