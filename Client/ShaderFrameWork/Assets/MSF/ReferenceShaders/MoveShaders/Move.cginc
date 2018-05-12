///----预定义的变量
#define PI            3.14159265359f
#define TWO_PI        6.28318530718f
#define FOUR_PI       12.56637061436f
#define INV_PI        0.31830988618f
#define INV_TWO_PI    0.15915494309f
#define INV_FOUR_PI   0.07957747155f
#define HALF_PI       1.57079632679f
#define INV_HALF_PI   0.636619772367f

#define INV_2PI 0.15915494309189533576888376337251
#define INV_2PIx2 0.31830988618379067153776752674502


//Linear - unity_ColorSpaceGrey.r is 0.19
//Gamma - unity_ColorSpaceGrey.r is 0.5			
//linear ? 1 : 0 = (Grey - 0.5) / (0.19 - 0.5) = one clever MAD instruction
#define IS_LINEAR ((-3.22581*unity_ColorSpaceGrey.r) + 1.6129)
#define IS_GAMMA  (( 3.22581*unity_ColorSpaceGrey.r) - 0.6129)

//x: IS_LINEAR, y: IS_GAMMA
#define IS_GAMMA_LINEAR (half2(3.22581,-3.22581)*unity_ColorSpaceGrey.rr + half2(-0.6129,1.6129))

///---函数头文件

///---函数本体
//-------------------------- Normal distribution functions --------------------------------------------
float NormalDistribution_GGX(float a, float NdH)
{
	// Isotropic ggx.
	float a2 = a*a;
	float NdH2 = NdH * NdH;

	float denominator = NdH2 * (a2 - 1.0f) + 1.0f;
	denominator *= denominator;
	denominator *= PI;

	return a2 / denominator;
}

float NormalDistribution_BlinnPhong(float a, float NdH)
{
	return (1 / (PI * a * a)) * pow(NdH, 2 / (a * a) - 2);
}

float NormalDistribution_Beckmann(float a, float NdH)
{
	float a2 = a * a;
	float NdH2 = NdH * NdH;

	return (1.0f/(PI * a2 * NdH2 * NdH2 + 0.001)) * exp( (NdH2 - 1.0f) / ( a2 * NdH2));
}
//-------------------------------
float Fresnel_Schlick(float u)
{
	float m = saturate(1.0f - u);
	float m2 = m * m;
	return m2 * m2 * m;
}

float3 Fresnel_Schlick(float3 specularColor, float3 h, float3 v)
{
	return (specularColor + (1.0f - specularColor) * pow((1.0f - saturate(dot(v, h))), 5));
}

float3 Specular_F_Roughness(float3 specularColor,float a ,float3 h,float3 v)
{
	// Sclick using roughness to attenuate fresnel.
	return (specularColor + (max(1.0f-a, specularColor) - specularColor) * pow((1 - saturate(dot(v, h))), 5));
}
//---------------------------------------------------------------
float Geometric_Smith_Schlick_GGX(float a, float NdV, float NdL)
{
	// Smith schlick-GGX.
	float k = a * 0.5f;
	float GV = NdV / (NdV * (1 - k) + k);
	float GL = NdL / (NdL * (1 - k) + k);

	return GV * GL;
}

//----------------------------------------------------------------
			
float Specular_D(float a, float NdH)
{
	return NormalDistribution_GGX(a,NdH);
}
float3 Specular_F(float3 specularColor, float3 h, float3 v)
{
	return Fresnel_Schlick(specularColor,h,v);
}
float Specular_G(float a, float NdV, float NdL, float NdH, float VdH, float LdV)
{
	return Geometric_Smith_Schlick_GGX(a, NdV, NdL);
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

//边缘光,内发光;
float3 RimColor(float3 rimColor,float3 N,float3 V,float rimAttenuation,float rimIntensity)
{
	return rimColor * pow(1.0 - max(0,dot(N,V)),rimAttenuation) * rimIntensity;
}


//------------Eye---------------------------------------------------------------------------
float Eye_CorneaSpecIns(float corneaGloss,float3 corneaSpecularColor,float3 N,float3 L,float3 V)
{
	float P2_13 = 8192;
	float3 H = normalize(L + V);
	float NdH = dot(N,H)*0.5f+0.5f;
	float HdL = dot(H,L)*0.5f+0.5f;
	float VdH = dot(V,H)*0.5f+0.5f;

	float _SP = pow(P2_13,corneaGloss);
	
	float d = (_SP + 2) / (8 * PI) * pow(NdH,_SP);
	float f = corneaSpecularColor + (1 - corneaSpecularColor) * pow(2,-10 * HdL);
	float k = min(1,corneaGloss + 0.545);
	float v = 1/(k * VdH*VdH + (1-k));

	float SpecIns = d * f * v;
	return SpecIns;
}

float Eye_IrisScleraSpec(float irisGloss,float3 corneaSpecularColor,float3 N,float3 L,float3 V,float mask)
{
	float P2_13 = 8192;
	float3 H = normalize(L + V);
	float NdH = dot(N,H)*0.5f+0.5f;
	float HdL = dot(H,L)*0.5f+0.5f;
	float VdH = dot(V,H)*0.5f+0.5f;

	float _SP = lerp(pow(P2_13,lerp(1.05,1.8,irisGloss)),pow(P2_13,irisGloss),mask);

	float d = (_SP + 2) / (8 * PI) * pow(max(0,NdH), _SP);
	float f = corneaSpecularColor + (1 - corneaSpecularColor)*pow(2, -10 * HdL);
	float k = min(1, irisGloss + 0.545);
	float v = 1 / (k* VdH*VdH + (1 - k));

	float SpecIns = d * f * v;
	return SpecIns;
}

float Pow5(float a)
{
	return pow(a,5);
}

//LightWrapping--------------------------------------------------------------------------------
float3 MyLightWrapping(float3 skin,float3 lightWrappingColor,float oMax,float lightWrappingIntensity,float3 N,float3 V,float atten,float inten)
{
	float NdotV = pow( 1-(dot( N, V )*0.5 + 0.5),atten)*inten;
	float lightWrapping = (1-skin) * oMax;
	return lightWrappingColor * lightWrapping * lightWrappingIntensity*NdotV ;
}

float3 LightWrapping_NdotL(float3 albedoColor ,float3 lightWrappingColor,float lightWrappingIntensity,float roughness,float3 N,float3 L,float3 V,float3 attenColor)
{	
	float3 H = normalize(V + L);
	float NdotL = max(0,dot(N, L));
	float LdotH = saturate(dot(L, H));
	float NdotV = abs(dot( N, V ));

	float3 w = (albedoColor * lightWrappingColor.rgb*lightWrappingIntensity)*0.5;
	float3 NdotLWrap = dot(N,L) * (1.0 - w);
	float3 forwardLight = max(float3(0,0,0),NdotLWrap + w);

	half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
    float nlPow5 = Pow5(1-NdotLWrap);
    float nvPow5 = Pow5(1-NdotV);
    float3 directDiffuse = (forwardLight + ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL)) * attenColor;
	
	return directDiffuse;
}


