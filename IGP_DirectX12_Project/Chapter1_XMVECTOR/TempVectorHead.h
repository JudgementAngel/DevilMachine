#ifndef TempVectorHead
#define TempVectorHead

#include <windows.h>
#include <DirectXMath.h>
#include <DirectXPackedVector.h>
#include <iostream>

using namespace std;
using namespace DirectX;
using namespace DirectX::PackedVector;

// ÷ÿ‘ÿ "<<" ‘ÀÀ„∑˚
ostream& XM_CALLCONV operator<< (ostream& os, FXMVECTOR v)
{
	XMFLOAT4 dest;
	XMStoreFloat4(&dest, v);

	os << "(" << dest.x << "," << dest.y << "," << dest.z << dest.w<< ")";
	return os;
}

#endif // TempVectorHead
