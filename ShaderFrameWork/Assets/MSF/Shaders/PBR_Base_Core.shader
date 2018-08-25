// 参考Unity Standard Shader
// 暂时不考虑以下情况：
//		灯光贴图、灯光探针、反射探针
//		ForwardAdd、Deferred、Meta
// 需改善效果：
// 		渲染太油腻、金属和非金属质感的区分不够明显
Shader "Move/PBR_Base_Core"
{
	Properties
	{
		_Color("颜色", Color) = (1,1,1,1)
        _MainTex("漫反射纹理(RGB)透明通道(A)", 2D) = "white" {}

        _Roughness ("粗糙度",Float) = 1
        _RoughnessMap("粗糙度贴图", 2D) = "white" {}
        _Metallic ("金属度",Float) = 1
        _MetallicMap("金属度贴图", 2D) = "white" {}

        _BumpMap("法线贴图", 2D) = "bump" {}
        _BumpScale("法线强度", Float) = 1.0
        
        [Toggle(ENABLE_PARALLAX)] _EnableParallax("是否使用视差效果?",Float) = 0
        _HeightScale ("视差缩放", Range (0.005, 0.08)) = 0.02
		_HeightMap ("视差图", 2D) = "black" {}

        _OcclusionStrength("AO 强度", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("AO 贴图", 2D) = "white" {}

		[Toggle(ENABLE_EMISSION)] _EnableEmission("是否使用自发光?",Float) = 0
        _EmissionColor("自发光颜色", Color) = (0,0,0)
        _EmissionIntensity ("自发光强度",Float) = 1
        _EmissionMap("自发光贴图", 2D) = "white" {}

        [Toggle(USE_VERTEX_GI)] _UseVertexGI("是否使用实时逐顶点光照?",Float) = 0
        [Toggle(USE_UNITY_CUBE)] _UseUnityCube("是否使用UnityCube?",Float) = 0
		_EnvMap("环境贴图",Cube) = "_Skybox"{}
		_MipCount("_MipCount",Float) = 8
        _EnvColor ("环境颜色",Color) = (1,1,1,0.5) 
        _EnvScale ("环境强度",Float) = 1.0

        _Cutoff("Alpha 剔除",Range(0,1)) = 0.5

       	[Enum(Off,0,On,1)] _ZWrite ("是否写入深度:",Float) = 1
       	[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试模式:",Float) = 4
       	[Enum(UnityEngine.Rendering.CullMode)] _Cull("裁剪模式:",Float) = 2
       	[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src 混合模式:",Float) = 1
       	[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst 混合模式:",Float) = 0
       	
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }



		Pass
		{
			Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_Cull]

            CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase
			#pragma shader_feature ENABLE_EMISSION
			#pragma shader_feature ENABLE_PARALLAX
			#pragma shader_feature USE_UNITY_CUBE
			#pragma shader_feature USE_VERTEX_GI

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			#ifdef UNITY_COLORSPACE_GAMMA 
				#define unity_ColorSpaceGrey fixed4(0.5, 0.5, 0.5, 0.5)
				#define unity_ColorSpaceDouble fixed4(2.0, 2.0, 2.0, 2.0)
				#define unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
				#define unity_ColorSpaceLuminance half4(0.22, 0.707, 0.071, 0.0) // Legacy: alpha is set to 0.0 to specify gamma mode 
			#else // Linear values 
				#define unity_ColorSpaceGrey fixed4(0.214041144, 0.214041144, 0.214041144, 0.5)
				#define unity_ColorSpaceDouble fixed4(4.59479380, 4.59479380, 4.59479380, 2.0)
				#define unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%) 
				#define unity_ColorSpaceLuminance half4(0.0396819152, 0.458021790, 0.00609653955, 1.0) // Legacy: alpha is set to 1.0 to specify linear mode
			#endif

			#define UNITY_SPECCUBE_LOD_STEPS (6)
			#define MOVE_SPECCUBE_LOD_STEPS (_MipCount)
			
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				half4 tangent : TANGENT;
				half3 normal : NORMAL;
			};

			struct v2f_forwardbase
			{
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float3 eyeVec : TEXCOORD1;
				float4 tangentToWorld_tangentView[3] : TEXCOORD2;
				half4 ambient : TEXCOORD5;
				UNITY_SHADOW_COORDS(6)
				float3 worldPos : TEXCOORD7;
			};

			fixed4 _Color; 
			fixed4 _LightColor0;
			sampler2D _MainTex; float4 _MainTex_ST;			
			sampler2D _OcclusionMap; half _OcclusionStrength;
			sampler2D _HeightMap; half _HeightScale;
			sampler2D _EmissionMap; half4 _EmissionColor; half _EmissionIntensity; 
			sampler2D _RoughnessMap; half _Roughness;
			sampler2D _MetallicMap; half _Metallic;
			sampler2D _BumpMap; half _BumpScale;

			#ifdef USE_UNITY_CUBE
				// samplerCUBE unity_SpecCube0; // 在HLSLSupport.cginc中已经声明
			#else
				samplerCUBE _EnvMap;
				fixed _MipCount;
			#endif
			half4 _EnvColor; half _EnvScale;
		

			half _Cutoff;



			v2f_forwardbase vert (appdata v)
			{
				v2f_forwardbase o = (v2f_forwardbase)0;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = TRANSFORM_TEX(v.uv0, _MainTex);
				float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos = posWorld;
				o.eyeVec = posWorld.xyz - _WorldSpaceCameraPos;
				

				half3 normalWorld = UnityObjectToWorldNormal(v.normal);
				half3 tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
				half3 binormalWorld = cross(normalWorld,tangentWorld) * v.tangent.w;

				o.tangentToWorld_tangentView[0].xyz = tangentWorld;
				o.tangentToWorld_tangentView[1].xyz = binormalWorld;
				o.tangentToWorld_tangentView[2].xyz = normalWorld;

				float3x3 rotation = float3x3(tangentWorld,binormalWorld,normalWorld);
				half3 viewDirForParallax = mul (rotation, UnityWorldSpaceViewDir(o.worldPos));
				
				o.tangentToWorld_tangentView[0].w = viewDirForParallax.x;
				o.tangentToWorld_tangentView[1].w = viewDirForParallax.y;
				o.tangentToWorld_tangentView[2].w = viewDirForParallax.z;
				
				#if USE_VERTEX_GI
					o.ambient.rgb = Shade4PointLights (
		                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
		                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
		                unity_4LightAtten0, o.worldPos, normalWorld);
				#else
					o.ambient.rgb = 0.0f.xxx;
				#endif


				// SH 光照一部分在顶点中计算，一部分在片段中计算
				#ifdef UNITY_COLORSPACE_GAMMA
		            o.ambient.rgb = GammaToLinearSpace (o.ambient.rgb);
		        #endif
		        o.ambient.rgb += SHEvalLinearL2 (half4(normalWorld, 1.0));

				// o.ambient.rgb = max(half3(0,0,0), ShadeSH9 (half4(normalWorld, 1.0)));//简化版本，只在Vertex中计算
				// o.ambient.rgb += UNITY_LIGHTMODEL_AMBIENT.rgb;//不适用SH的版本
				UNITY_TRANSFER_SHADOW(o, v.uv1);
				return o;
			}
			
			struct Move_FragmentData
			{
				 half3 diffColor,specColor;
				 half oneMinusReflectivity,roughness;
				 float3 normalWorld,eyeVec,posWorld;
				 half alpha;
			}; 


			Move_FragmentData Move_FragmentSetup(inout float2 i_tex,float3 i_eyeVec,half3 i_viewDirForParallax ,float4 tangentToWorld[3],float3 i_posWorld)
			{
				Move_FragmentData s = (Move_FragmentData)0;

				#ifdef ENABLE_PARALLAX// Parallax
					float2 offset = ParallaxOffset(tex2D(_HeightMap,i_tex.xy).g,_HeightScale,i_viewDirForParallax);
					i_tex += offset.xy;
				#endif
				// Normal
				half3 normalTangent = UnpackNormal(tex2D(_BumpMap,i_tex.xy));
				normalTangent = lerp(float3(0,0,1),normalTangent,_BumpScale);
				s.normalWorld = normalize(tangentToWorld[0].xyz * normalTangent.x + tangentToWorld[1].xyz * normalTangent.y + tangentToWorld[2].xyz * normalTangent.z);

				fixed4 mainTex = tex2D(_MainTex,i_tex.xy); 
				clip(mainTex.a - _Cutoff);
				s.diffColor = _Color.rgb * mainTex.rgb;
				s.alpha = mainTex.a;

				half metallic = tex2D(_MetallicMap,i_tex.xy).r * _Metallic;
				half roughness = tex2D(_RoughnessMap,i_tex.xy).r * _Roughness;

				s.specColor = lerp(unity_ColorSpaceDielectricSpec.rgb ,s.diffColor,metallic);
				s.oneMinusReflectivity = (1-metallic) * unity_ColorSpaceDielectricSpec.a;

				s.diffColor *= s.oneMinusReflectivity;
				s.roughness = roughness;
				s.eyeVec = normalize(i_eyeVec);
				s.posWorld = i_posWorld;
				return s;

			}

			struct Move_GI
			{
				half3 color;
				half3 dir;

				half3 indirectDiffuse;
				half3 indirectSpecular;
			}; 

			float PerceptualRoughnessToMip(float perceptualRoughness,half mipCount)
			{
				half level = 3 - 1.15 * log2(perceptualRoughness);
				return mipCount - 1- level;
			}




//-----------------------------------------------------------------------------------------------------------------------------------
			inline half3 BoxProjectedCubemapDirection (half3 worldRefl, float3 worldPos, float4 cubemapCenter, float4 boxMin, float4 boxMax)
			{
			    // Do we have a valid reflection probe?
			    // 我们是否有有效的反射探针？
			    UNITY_BRANCH
			    if (cubemapCenter.w > 0.0)
			    {
			        half3 nrdir = normalize(worldRefl);

			        #if 1
			            half3 rbmax = (boxMax.xyz - worldPos) / nrdir;
			            half3 rbmin = (boxMin.xyz - worldPos) / nrdir;

			            half3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

			        #else // Optimized version
			            half3 rbmax = (boxMax.xyz - worldPos);
			            half3 rbmin = (boxMin.xyz - worldPos);

			            half3 select = step (half3(0,0,0), nrdir);
			            half3 rbminmax = lerp (rbmax, rbmin, select);
			            rbminmax /= nrdir;
			        #endif

			        half fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

			        worldPos -= cubemapCenter.xyz;
			        worldRefl = worldPos + nrdir * fa;
			    }
			    return worldRefl;
			}

			// // Unity 全局光照输入参数结构体
			// struct UnityGIInput
			// {
			//     UnityLight light; // pixel light, sent from the engine // 逐像素灯光，从引擎中输入

			//     float3 worldPos; // 世界空间顶点位置
			//     half3 worldViewDir; // 世界空间视线向量
			//     half atten; // 灯光衰减，直射光非0即1，点光源和聚光灯具有衰减，也用来实现自阴影
			//     half3 ambient; // 环境光

			//     // interpolated lightmap UVs are passed as full float precision data to fragment shaders
			//     // 内置光照贴图UV，作为完整的float 精度数据传递给fragment 着色器
			//     // so lightmapUV (which is used as a tmp inside of lightmap fragment shaders) should
			//     // also be full float precision to avoid data loss before sampling a texture.
			//     // 所以 lightmapUV (作为临时参数被用于在Fragment着色器中传递灯光贴图UV)也应该
			//     // 使用完整的float精度以避免在采样贴图之前丢失精度。

			//     float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV // xy是静态的灯光贴图UV，zw是动态的灯光贴图UV

			//     // @TODO
			//     #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
			//     float4 boxMin[2];
			//     #endif
			//     #ifdef UNITY_SPECCUBE_BOX_PROJECTION
			//     float4 boxMax[2];
			//     float4 probePosition[2];
			//     #endif

			//     // HDR cubemap properties, use to decompress HDR texture
			//     // HDR cubemap 属性，用来解压HDR贴图
			//     float4 probeHDR[2];
			// };

			// half3 Unity_GlossyEnvironment (UNITY_ARGS_TEXCUBE(tex), half4 hdr, half roughness)
			// {
			//     half perceptualRoughness = roughness /* perceptualRoughness */ ;

			
			//     perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);
			


			//     half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
			//     half3 R = glossIn.reflUVW;
			//     half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);

			//     return DecodeHDR(rgbm, hdr);
			// }

			// inline UnityGIInput SetUnityGIInput(Move_FragmentData s )
			// {
			// 	UnityGIInput d;
			//     d.light = light;
			//     d.worldPos = s.posWorld;
			//     d.worldViewDir = -s.eyeVec;
			//     d.atten = atten;

			//     // 是否使用灯光贴图，使用灯光贴图就不使用环境光
			//     #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
			//         d.ambient = 0;
			//         d.lightmapUV = i_ambientOrLightmapUV;
			//     #else
			//         d.ambient = i_ambientOrLightmapUV.rgb;
			//         d.lightmapUV = 0;
			//     #endif

			//     // @TODO: unity_SpecCube0_HDR unity_SpecCube1_HDR 具体指什么
			//     d.probeHDR[0] = unity_SpecCube0_HDR;
			//     d.probeHDR[1] = unity_SpecCube1_HDR;
			//     #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
			//       d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending // w 存储用混合的差值变量
			//     #endif

			//     // @TODO
			//     #ifdef UNITY_SPECCUBE_BOX_PROJECTION
			//       d.boxMax[0] = unity_SpecCube0_BoxMax;
			//       d.probePosition[0] = unity_SpecCube0_ProbePosition;
			//       d.boxMax[1] = unity_SpecCube1_BoxMax;
			//       d.boxMin[1] = unity_SpecCube1_BoxMin;
			//       d.probePosition[1] = unity_SpecCube1_ProbePosition;
			//     #endif

			//       return d;
			// }

			// inline half3 UnityGI_IndirectSpecular(UnityGIInput data, half occlusion, half3 reflUVW,half roughness)
			// {
			//     half3 specular;

			//     #ifdef UNITY_SPECCUBE_BOX_PROJECTION
			//         // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
			//         // 我们将会直接调整 glossIn 中的 reflUVW （因为我们将它传递到 Unity_GlossEnvironment 两次，用于 probe0 和 probe1），所以请保持原始传递到BoxProjectedCubemapDirection
			//         half3 originalReflUVW = glossIn.reflUVW;
			//         glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
			//     #endif

			//     #ifdef _GLOSSYREFLECTIONS_OFF
			//         specular = unity_IndirectSpecColor.rgb;
			//     #else
			//         half3 env0 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], roughness);
			//         #ifdef UNITY_SPECCUBE_BLENDING
			//             const float kBlendFactor = 0.99999;
			//             float blendLerp = data.boxMin[0].w;
			//             UNITY_BRANCH
			//             if (blendLerp < kBlendFactor)
			//             {
			//                 #ifdef UNITY_SPECCUBE_BOX_PROJECTION
			//                     glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[1], data.boxMin[1], data.boxMax[1]);
			//                 #endif

			//                 half3 env1 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), data.probeHDR[1], roughness);
			//                 specular = lerp(env1, env0, blendLerp);
			//             }
			//             else
			//             {
			//                 specular = env0;
			//             }
			//         #else
			//             specular = env0;
			//         #endif
			//     #endif

			//     return specular * occlusion;
			// }
//-----------------------------------------------------------------------------------------------------------------------------------

			Move_GI Move_FragmentGI(Move_FragmentData s,half occlusion,half4 i_ambient,half atten,half3 lightColor,half3 worldSpaceLightDir)
			{
				Move_GI gi = (Move_GI)0;
				gi.color = lightColor * atten;
				gi.dir = worldSpaceLightDir;

				// SH 光照一部分在顶点中计算，一部分在片段中计算
				half3 ambient_contrib = 0.0;
		        ambient_contrib = SHEvalLinearL0L1 (half4(s.normalWorld, 1.0));
		        gi.indirectDiffuse = max(half3(0, 0, 0), i_ambient + ambient_contrib);
				#ifdef UNITY_COLORSPACE_GAMMA
					gi.indirectDiffuse = LinearToGammaSpace(gi.indirectDiffuse);
				#endif
				gi.indirectDiffuse *= occlusion;
				

				/// EnvCol
				half3 reflUVW = reflect(s.eyeVec,s.normalWorld);
				//reflUVW = BoxProjectedCubemapDirection (reflUVW, s.posWorld, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);

				half perceptualRoughness = s.roughness;

				perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);

			#ifdef USE_UNITY_CUBE
				half mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,reflUVW,mip) * _EnvColor * _EnvScale;
			#else
				half mip = perceptualRoughness * MOVE_SPECCUBE_LOD_STEPS;
				half4 rgbm = texCUBElod(_EnvMap,half4(reflUVW,mip)) * _EnvColor * _EnvScale ;
				rgbm *= unity_ColorSpaceDouble; // Unity在烘焙反射贴图之后，会自动乘上这一项，即：如果使用烘焙后的贴图做CubeMap就不用乘这个
			#endif

    			half3 envCol = DecodeHDR(rgbm,unity_SpecCube0_HDR);

				gi.indirectSpecular = envCol * occlusion;

			
				// float3 reflUVW = reflect(s.eyeVec,s.normalWorld);
				// gi.indirectSpecular = UnityGI_IndirectSpecular(UnityGIInput data, occlusion, reflUVW,s.roughness)
				return gi;
			}
		

			inline half Pow5 (half x)
			{
			    return x*x * x*x * x;
			}

			// Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
			half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
			{
			    half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
			    // Two schlick fresnel term
			    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
			    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

			    return lightScatter * viewScatter;
			}

			inline float GGXTerm (float NdotH, float roughness)
			{
			    float a2 = roughness * roughness;
			    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
			    return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
			                                            // therefore epsilon is smaller than what can be represented by half
			}
			
			inline half SmithJointGGXVisibilityTerm (half NdotL, half NdotV, half roughness)
			{
				half a = roughness;
			    half lambdaV = NdotL * (NdotV * (1 - a) + a);
			    half lambdaL = NdotV * (NdotL * (1 - a) + a);

			    return 0.5f / (lambdaV + lambdaL + 1e-5f);
			}

			inline half3 FresnelTerm (half3 F0, half cosA)
			{
			    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
			    return F0 + (1-F0) * t;
			}

			inline half3 FresnelLerp (half3 F0, half3 F90, half cosA)
			{
			    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
			    return lerp (F0, F90, t);
			}
			
			// inline half Remap(float Val,float iMin,float iMax,float oMin,float oMax)
			// {
			// 	return (oMin + ((Val - iMin) * (oMax - oMin))/(iMax - iMin));
			// }

			// inline half3 RemapLerp(half3 F0,half3 F90,half val)
			// {
			// 	half t = saturate(Remap(val,0.95,1,0,1));
			// 	return lerp (0, F0 ,t) ;
			// }

			// Diffuse:Disney
			// Specular: 基于Torrance-Sparrow micro-facet 光照模型
			// 		NDF: GGX ; V项: Smith; Fresnel: Schlick的近似
			//   BRDF = kD / pi + kS * (D * V * F) / 4
			//   I = BRDF * NdotL
			// HACK: 这里没有给漫反射项除 pi，并且给高光项乘pi。
			// 原因是：防止在引擎中的结果和传统的相比太暗；SH和非重要的灯光也得除pi;
			half4 Move_BRDF_PBS(Move_FragmentData s,Move_GI gi)
			{
				float perceptualRoughness = s.roughness;
				float roughness = perceptualRoughness * perceptualRoughness;

				float3 lightDir = gi.dir;
				float3 viewDir = -normalize(s.eyeVec); 
				float3 normal = s.normalWorld;
				float3 halfDir = normalize (lightDir + viewDir);

				half nv = abs(dot(normal,viewDir));
				half nl = saturate(dot(normal,lightDir));
				float nh = saturate(dot(normal, halfDir));
				half lv = saturate(dot(lightDir, viewDir));
    			half lh = saturate(dot(lightDir, halfDir));

    			// DiffuseTerm
    			half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    			// SpecularTerm: GGX
    			roughness = max(roughness,0.002);
    			half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    			float D = GGXTerm (nh, roughness);

    			half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later
    			#ifdef UNITY_COLORSPACE_GAMMA
        			specularTerm = sqrt(max(1e-4h, specularTerm));
				#endif
        		
        		specularTerm = max(0, specularTerm * nl);

			    half surfaceReduction;
				#ifdef UNITY_COLORSPACE_GAMMA
			        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
				#else
			        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
				#endif

			    half grazingTerm = saturate(1-perceptualRoughness + (1-s.oneMinusReflectivity));

			    half3 color =   s.diffColor * (gi.indirectDiffuse + gi.color * diffuseTerm) 
                    + specularTerm * gi.color * FresnelTerm (s.specColor, lh) 
                    + surfaceReduction * gi.indirectSpecular * FresnelLerp (s.specColor, grazingTerm, nv);

                return half4(color,1);
			}

			fixed4 frag (v2f_forwardbase i) : SV_Target
			{
				Move_FragmentData s = Move_FragmentSetup(i.tex,i.eyeVec,
					half3(i.tangentToWorld_tangentView[0].w,i.tangentToWorld_tangentView[1].w,i.tangentToWorld_tangentView[2].w),
					i.tangentToWorld_tangentView,i.worldPos); 

				/*
				 half3 diffColor,specColor;
				 half oneMinusReflectivity,roughness;
				 float3 normalWorld,eyeVec,posWorld;
				 half alpha;
				
				return s.posWorld.rgbr;
				*/
				// return s.eyeVec.rgbr;
				UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld); 

				half occlusion = lerp(1,tex2D(_OcclusionMap,i.tex.xy).g,_OcclusionStrength);
				// return occlusion.xxxx;
				Move_GI gi = Move_FragmentGI(s,occlusion,i.ambient,atten,_LightColor0.rgb,_WorldSpaceLightPos0.xyz);
				/*
				half3 color;
				half3 dir;

				half3 indirectDiffuse;
				half3 indirectSpecular;
				*/
				// return gi.indirectSpecular.rgbr;
				half4 col = Move_BRDF_PBS(s,gi);

				#ifdef ENABLE_EMISSION
					col.rgb += tex2D(_EmissionMap,i.tex.xy).rgb * _EmissionColor.rgb * _EmissionIntensity;
				#endif

				col.a = s.alpha;
				
				// return gi.indirectSpecular.rgbr;
				return col;
			}
			ENDCG
		}
      

	}

	Fallback "Diffuse"
}
