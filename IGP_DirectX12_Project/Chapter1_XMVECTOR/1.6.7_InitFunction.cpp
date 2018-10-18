/*
#include <windows.h>
#include <DirectXMath.h>
#include <DirectXPackedVector.h>
#include <iostream>
#include "TempVectorHead.h"

using namespace std;
using namespace DirectX;
using namespace DirectX::PackedVector;

int main()
{
	cout.setf(ios_base::boolalpha);

	// 检查是否支持 SSE2 (Pentium4, AMD K8, and above)
	if(!XMVerifyCPUSupport())
	{
		cout << "directx math not supported" << endl;
		return 0;
	}

	XMVECTOR p = XMVectorZero();
	XMVECTOR q = XMVectorSplatOne();
	XMVECTOR u = XMVectorSet(1.0f,2.0f,3.0f,0.0f);
	XMVECTOR v = XMVectorReplicate(-2.0f);
	XMVECTOR w = XMVectorSplatZ(u);

	cout << "p =" << p << endl;
	cout << "q =" << q << endl;
	cout << "u =" << u << endl;
	cout << "v =" << v << endl;
	cout << "w =" << w << endl;

	return 0;
}
*/