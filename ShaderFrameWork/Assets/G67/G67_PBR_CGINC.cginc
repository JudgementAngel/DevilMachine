#ifndef G67_PBR_CGINC 
#define G67_PBR_CGINC

float PerceptualRoughnessToMip(float perceptualRoughness,half mipCount)
{
	half level = 3 - 1.15 * log2(perceptualRoughness);
	return mipCount - 1- level;
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


// Physically based shading model
// parameterized with the below options

// Diffuse model
// 0: Lambert
// 1: Burley
// 2: Oren-Nayar
#define PHYSICAL_DIFFUSE	0

// Microfacet distribution function
// 0: Blinn
// 1: Beckmann
// 2: GGX
#define PHYSICAL_SPEC_D		2

// Geometric attenuation or shadowing
// 0: Implicit
// 1: Neumann
// 2: Kelemen
// 3: Schlick
// 4: Smith (matched to GGX)
// 5: Schlick_disney
#define PHYSICAL_SPEC_G		5

// Fresnel
// 0: None
// 1: Schlick
// 2: Fresnel
#define PHYSICAL_SPEC_F		1

//helper functions
#ifndef PI
	#define PI 3.1415926535897932384626433832795
#endif
#define MIN_ROUGHNESS 0.08

float Square( float x )
{
	return x*x;
}
float3 Square( float3 x )
{
	return x*x;
}
// Clamp the base, so it's never <= 0.0f (INF/NaN).
float PhongShadingPow(float X, float Y)
{
	return pow(max(abs(X),0.000001f),Y);
}

float3 Diffuse_Lambert( float3 DiffuseColor )
{
	return DiffuseColor / PI;
}

// [Burley 2012, "Physically-Based Shading at Disney"]
float3 Diffuse_Burley( float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH )
{
	float FD90 = 0.5 + 2 * VoH * VoH * Roughness;
	float FdV = 1 + (FD90 - 1) * exp2( (-5.55473 * NoV - 6.98316) * NoV );
	float FdL = 1 + (FD90 - 1) * exp2( (-5.55473 * NoL - 6.98316) * NoL );
	return DiffuseColor * ( 1 / PI * FdV * FdL );
}

// [Gotanda 2012, "Beyond a Simple Physically Based Blinn-Phong Model in Real-Time"]
float3 Diffuse_OrenNayar( float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH )
{
	float VoL = 2 * VoH - 1;
	float m = Roughness * Roughness;
	float m2 = m * m;
	float C1 = 1 - 0.5 * m2 / (m2 + 0.33);
	float Cosri = VoL - NoV * NoL;
	float C2 = 0.45 * m2 / (m2 + 0.09) * Cosri * ( Cosri >= 0 ? min( 1, NoL / NoV ) : NoL );
	return DiffuseColor / PI * ( NoL * C1 + C2 );
}

// [Blinn 1977, "Models of light reflection for computer synthesized pictures"]
float D_Blinn( float Roughness, float NoH )
{
	float m = Roughness * Roughness;
	float m2 = m * m;
	float n = 2 / m2 - 2;
	return (n+2) / (2*PI) * PhongShadingPow( NoH, n );		// 1 mad, 1 exp, 1 mul, 1 log
}

// [Beckmann 1963, "The scattering of electromagnetic waves from rough surfaces"]
float D_Beckmann( float Roughness, float NoH )
{
	float m = Roughness * Roughness;
	float m2 = m * m;
	float NoH2 = NoH * NoH;
	return exp( (NoH2 - 1) / (m2 * NoH2) ) / ( PI * m2 * NoH2 * NoH2 );
}

// GGX / Trowbridge-Reitz
// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
float D_GGX( float Roughness, float NoH )
{
	float m = Roughness * Roughness;
	float m2 = m * m;
	float d = ( NoH * m2 - NoH ) * NoH + 1;	// 2 mad
	return m2 / ( PI*d*d );					// 2 mul, 1 rcp
}

// Anisotropic GGX
// [Burley 2012, "Physically-Based Shading at Disney"]
float D_GGXaniso( float RoughnessX, float RoughnessY, float NoH, float3 H, float3 X, float3 Y )
{
	float mx = RoughnessX * RoughnessX;
	float my = RoughnessY * RoughnessY;
	float XoH = dot( X, H );
	float YoH = dot( Y, H );
	float d = XoH*XoH / (mx*mx) + YoH*YoH / (my*my) + NoH*NoH;
	return 1 / ( PI * mx*my * d*d );
}

float G_Implicit()
{
	return 0.25;
}

// [Neumann et al. 1999, "Compact metallic reflectance models"]
float G_Neumann( float NoV, float NoL )
{
	return 1 / ( 4 * max( NoL, NoV ) );
}

// [Kelemen 2001, "A microfacet based coupled specular-matte brdf model with importance sampling"]
float G_Kelemen( float VoH )
{
	return rcp( 4 * VoH * VoH );
}

// Tuned to match behavior of Vis_Smith
// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float G_Schlick( float Roughness, float NoV, float NoL )
{
	float k = Square( Roughness ) * 0.5;
	float Vis_SchlickV = NoV * (1 - k) + k;
	float Vis_SchlickL = NoL * (1 - k) + k;
	return 0.25 / ( Vis_SchlickV * Vis_SchlickL );
}

// Smith term for GGX
// [Smith 1967, "Geometrical shadowing of a random rough surface"]
float G_Smith( float Roughness, float NoV, float NoL )
{
	float a = Square( Roughness );
	float a2 = a*a;

	float Vis_SmithV = NoV + sqrt( NoV * (NoV - NoV * a2) + a2 );
	float Vis_SmithL = NoL + sqrt( NoL * (NoL - NoL * a2) + a2 );
	return rcp( Vis_SmithV * Vis_SmithL );
}

// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float G_SmithJointApprox( float Roughness, float NoV, float NoL )
{
	float a = Square( Roughness );
	float Vis_SmithV = NoL * ( NoV * ( 1 - a ) + a );
	float Vis_SmithL = NoV * ( NoL * ( 1 - a ) + a );
	return 0.5 * rcp( Vis_SmithV + Vis_SmithL );
}

float3 F_None( float3 SpecularColor )
{
	return SpecularColor;
}

// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
// [Lagarde 2012, "Spherical Gaussian approximation for Blinn-Phong, Phong and Fresnel"]
float3 F_Schlick( float3 SpecularColor, float VoH )
{
	// Anything less than 2% is physically impossible and is instead considered to be shadowing 
	return SpecularColor + ( saturate( 50.0 * SpecularColor.g ) - SpecularColor ) * exp2( (-5.55473 * VoH - 6.98316) * VoH );

	//float Fc = exp2( (-5.55473 * VoH - 6.98316) * VoH );	// 1 mad, 1 mul, 1 exp 	//float Fc = pow( 1 - VoH, 5 );
	//return Fc + (1 - Fc) * SpecularColor;					// 1 add, 3 mad
}

float3 F_Fresnel( float3 SpecularColor, float VoH )
{
	float3 SpecularColorSqrt = sqrt( clamp( float3(0, 0, 0), float3(0.99, 0.99, 0.99), SpecularColor ) );
	float3 n = ( 1 + SpecularColorSqrt ) / ( 1 - SpecularColorSqrt );
	float3 g = sqrt( n*n + VoH*VoH - 1 );
	return 0.5 * Square( (g - VoH) / (g + VoH) ) * ( 1 + Square( ((g+VoH)*VoH - 1) / ((g-VoH)*VoH + 1) ) );
}


float3 Diffuse( float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH )
{
#if   PHYSICAL_DIFFUSE == 0
	return Diffuse_Lambert( DiffuseColor );
#elif PHYSICAL_DIFFUSE == 1
	return Diffuse_Burley( DiffuseColor, Roughness, NoV, NoL, VoH );
#elif PHYSICAL_DIFFUSE == 2
	return Diffuse_OrenNayar( DiffuseColor, Roughness, NoV, NoL, VoH );
#endif
}

float Distribution( float Roughness, float NoH )
{
#if   PHYSICAL_SPEC_D == 0
	return D_Blinn( Roughness, NoH );
#elif PHYSICAL_SPEC_D == 1
	return D_Beckmann( Roughness, NoH );
#elif PHYSICAL_SPEC_D == 2
	return D_GGX( Roughness, NoH );
#endif
}

// Vis = G / (4*NoL*NoV)
float GeometricVisibility( float Roughness, float NoV, float NoL, float VoH )
{
#if   PHYSICAL_SPEC_G == 0
	return G_Implicit();
#elif PHYSICAL_SPEC_G == 1
	return G_Neumann( NoV, NoL );
#elif PHYSICAL_SPEC_G == 2
	return G_Kelemen( VoH );
#elif PHYSICAL_SPEC_G == 3
	return G_Schlick( Roughness, NoV, NoL );
#elif PHYSICAL_SPEC_G == 4
	return G_Smith( Roughness, NoV, NoL );
#elif PHYSICAL_SPEC_G == 5
	// TODO
	// return G_Schlick_Disney( Roughness, NoV, NoL );	
#endif
}

float3 Fresnel( float3 SpecularColor, float VoH )
{
#if   PHYSICAL_SPEC_F == 0
	return F_None( SpecularColor );
#elif PHYSICAL_SPEC_F == 1
	return F_Schlick( SpecularColor, VoH );
#elif PHYSICAL_SPEC_F == 2
	return F_Fresnel( SpecularColor, VoH );
#endif
}

// uint BRDFReverseBits( uint bits )
// {
// #if SM5_PROFILE
// 	return reversebits( bits );
// #else
// 	bits = ( bits << 16) | ( bits >> 16);
// 	bits = ( (bits & 0x00ff00ff) << 8 ) | ( (bits & 0xff00ff00) >> 8 );
// 	bits = ( (bits & 0x0f0f0f0f) << 4 ) | ( (bits & 0xf0f0f0f0) >> 4 );
// 	bits = ( (bits & 0x33333333) << 2 ) | ( (bits & 0xcccccccc) >> 2 );
// 	bits = ( (bits & 0x55555555) << 1 ) | ( (bits & 0xaaaaaaaa) >> 1 );
// 	return bits;
// #endif
// }

// float2 Hammersley( uint Index, uint NumSamples, uint2 Random )
// {
// 	float E1 = frac( (float)Index / NumSamples + float( Random.x & 0xffff ) / (1<<16) );
// 	float E2 = float( BRDFReverseBits(Index) ^ Random.y ) * 2.3283064365386963e-10;
// 	return float2( E1, E2 );
// }

float2 JitterRandom( float2 Random)
{
	float2 hash = frac( Random * 49999 );
	return hash;
}

float3 ImportanceSampleGGX( float2 E, float Roughness, float3 N )
{
	float m = Roughness * Roughness;

	float Phi = 2 * PI * E.x;
	float CosTheta = sqrt( (1 - E.y) / ( 1 + (m*m - 1) * E.y ) );
	float SinTheta = sqrt( 1 - CosTheta * CosTheta );

	float3 H;
	H.x = SinTheta * cos( Phi );
	H.y = SinTheta * sin( Phi );
	H.z = CosTheta;

	float3 UpVector = abs(N.z) < 0.999 ? float3(0,0,1) : float3(1,0,0);
	float3 TangentX = normalize( cross( UpVector, N ) );
	float3 TangentY = cross( N, TangentX );
	// tangent to world space
	return TangentX * H.x + TangentY * H.y + N * H.z;
}

float3 CosWeightSample( float2 E, float3 N )
{
	//cos⁡(θ)=1−ε; φ=2πε
	float Phi = 2 * PI * E.x;
	float CosTheta = 1 - E.y;
	float SinTheta = sqrt( 1 - CosTheta * CosTheta );

	float3 H;
	H.x = SinTheta * cos( Phi );
	H.y = SinTheta * sin( Phi );
	H.z = CosTheta;

	float3 UpVector = abs(N.z) < 0.999 ? float3(0,0,1) : float3(1,0,0);
	float3 TangentX = normalize( cross( UpVector, N ) );
	float3 TangentY = cross( N, TangentX );
	// tangent to world space
	return TangentX * H.x + TangentY * H.y + N * H.z;
}

// float2 IntegrateBRDF(float Roughness, float NoV)
// {
// 	//homogenous, all vector in tangent space of
// 	float3 V;
// 	V.x = sqrt( 1.0f - NoV * NoV ); // sin
// 	V.y = 0;
// 	V.z = NoV; // cos
// 	float3 N = float3( 0, 0, 1 );

// 	float A = 0;	//A = D*G*(1-(1-VoH)^5)*NoL
// 	float B = 0;	//B = D*G*(1-VoH)^5*NoL
// 	const uint NumSamples = 4096;
// 	for( uint i = 0; i < NumSamples; i++ )
// 	{
// 		float2 Xi = g_randomTexture[i].xy;
// 		float3 H = ImportanceSampleGGX( Xi, Roughness, N );
// 		float3 L = 2 * dot( V, H ) * H - V;
// 		float NoL = saturate( L.z );
// 		float NoH = saturate( H.z );
// 		float VoH = saturate( dot( V, H ) );
// 		if( NoL > 0 )
// 		{
// 			float G = G_Smith( Roughness, NoV, NoL );//G_Smith pack with  1 / (4*NoL*NoV);
// 			float Fc = pow( 1 - VoH, 5 );
// 			// pdf = D * NoH / (4 * VoH)
// 			A += 4.0f * NoL * G * (1-Fc) * VoH / NoH;
// 			B += 4.0f * NoL * G * Fc * VoH / NoH;
// 		}
// 	}
// 	return float2(A, B) / NumSamples;
// }
// Texture2D		PreIntegratedGF;
// SamplerState	PreIntegratedGFSampler;

// half3 EnvBRDF( half3 SpecularColor, half Roughness, half NoV )
// {
// 	// Importance sampled preintegrated G * F
// 	float2 AB = Texture2DSampleLevel( PreIntegratedGF, PreIntegratedGFSampler, float2( NoV, Roughness ), 0 ).rg;
// 
// 	// Anything less than 2% is physically impossible and is instead considered to be shadowing 
// 	float3 GF = SpecularColor * AB.x + saturate( 50.0 * SpecularColor.g ) * AB.y;
// 	return GF;
// }

half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NoV )
{
	// [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
	// Adaptation to fit our G term.
	const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
	const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
	half4 r = Roughness * c0 + c1;
	half a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
	half2 AB = half2( -1.04, 1.04 ) * a004 + r.zw;

#if !(ES2_PROFILE || ES3_1_PROFILE)
	// Anything less than 2% is physically impossible and is instead considered to be shadowing
	// In ES2 this is skipped for performance as the impact can be small
	// Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
	AB.y *= saturate( 50.0 * SpecularColor.g );
#endif

	return SpecularColor * AB.x + AB.y;
}

half EnvBRDFApproxNonmetal( half Roughness, half NoV )
{
	// Same as EnvBRDFApprox( 0.04, Roughness, NoV )
	const half2 c0 = { -1, -0.0275 };
	const half2 c1 = { 1, 0.0425 };
	half2 r = Roughness * c0 + c1;
	return min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
}

half3 SimpleBRDF(in float3 L, in float3 N, in float3 V, in half NoV, in half NoL,
	in half3 DiffuseColor, in half3 SpecularColor, in half Roughness)
{
	float3 H = normalize(V + L);
	float NoH = saturate( dot(N, H) );
	
	half D = D_GGX( max(MIN_ROUGHNESS, Roughness), NoH );
	half G = G_Implicit();
	half3 F = F_None( SpecularColor );

	return DiffuseColor + (D * G) * F;
}

half3 SimpleBRDF_SPEC(in float3 L, in float3 N, in float3 V, in half NoV, in half NoL,
	in half3 SpecularColor, in half Roughness)
{
	float3 H = normalize(V + L);
	float NoH = saturate( dot(N, H) );

	half D = D_GGX( max(MIN_ROUGHNESS, Roughness), NoH );
	half G = G_Implicit();
	half3 F = F_None( SpecularColor );

	return (D * G) * F;
}

half NPR_SPEC_SCALE(in float3 L, in float3 N, in float3 V, in half Roughness)
{
	float3 H = normalize(V + L);
	float NoH = saturate( dot(N, H) );

	return D_GGX( max(MIN_ROUGHNESS, Roughness), NoH );
}

half3 PbrBRDF(in float3 L, in float3 N, in float3 V, in half NoV, in half NoL,
	in half3 DiffuseColor, in half3 SpecularColor, in half Roughness)
{
	float3 H = normalize(V + L);
	float NoH = saturate( dot(N, H) );
	float VoH = saturate( dot(V, H) );
	half3 DiffuseLighting = DiffuseColor;
	
	half D = D_GGX( max(MIN_ROUGHNESS, Roughness), NoH );
	half  G = G_Schlick( Roughness, NoV, NoL );
	half3 F = F_Schlick( SpecularColor, VoH );

	return DiffuseLighting + D*G*F;
}

half3 PbrBRDF_SPEC(in float3 L, in float3 N, in float3 V, in half NoV, in half NoL,
	in half3 SpecularColor, in half Roughness)
{
	float3 H = normalize(V + L);
	float NoH = saturate( dot(N, H) );
	float VoH = saturate( dot(V, H) );
	
	half D = D_GGX( max(MIN_ROUGHNESS, Roughness), NoH );
	half  G = G_Schlick( Roughness, NoV, NoL );
	half3 F = F_Schlick( SpecularColor, VoH );

	return D*G*F;
}



#endif // G67_PBR_CGINC
