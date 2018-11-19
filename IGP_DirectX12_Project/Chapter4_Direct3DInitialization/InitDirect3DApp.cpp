#include "../Common/d3dApp.h"
#include <DirectXColors.h>

using namespace DirectX;

class InitDirect3DApp :public D3DApp
{
public :
	InitDirect3DApp(HINSTANCE hInstance);
	~InitDirect3DApp();

	virtual bool Initialize() override;
private :
	virtual void OnResize() override;
	virtual void Update(const GameTimer& gt) override;
	virtual void Draw(const GameTimer& gt) override;
};

InitDirect3DApp::InitDirect3DApp(HINSTANCE hInstance):D3DApp(hInstance)
{
}

InitDirect3DApp::~InitDirect3DApp()
{
}

bool InitDirect3DApp::Initialize()
{
	if (!D3DApp::Initialize())return false;

	return true;
}

void InitDirect3DApp::OnResize()
{
	D3DApp::OnResize();
}

void InitDirect3DApp::Update(const GameTimer& gt)
{
}

void InitDirect3DApp::Draw(const GameTimer& gt)
{
	// 重用与命令录制相关的内存
	// 关联的Command List在GPU上执行完成时进行重置
	ThrowIfFailed(mDirectCmdListAlloc->Reset());

	// 通过ExecutedCommandList 将Command List 添加到 Command Queue后可以重置 Command List
	// 重用Command List 会重用内存
	ThrowIfFailed(mCommandList->Reset(mDirectCmdListAlloc.Get(), nullptr));

	// 指示资源使用情况的状态转换
	mCommandList->ResourceBarrier(1, &CD3DX12_RESOURCE_BARRIER::Transition(CurrentBackBuffer(), D3D12_RESOURCE_STATE_PRESENT, D3D12_RESOURCE_STATE_RENDER_TARGET));

	// 设置 viewport 和 scissor rect。它们需要在Command List 重置的时候重置
	mCommandList->RSSetViewports(1, &mScreenViewport);
	mCommandList->RSSetScissorRects(1, &mScissorRect);

	// 清空back buffer 和 depth/stencil buffer
	mCommandList->ClearRenderTargetView(CurrentBackBufferView(), Colors::LightSteelBlue, 0, nullptr);
	mCommandList->ClearDepthStencilView(DepthStencilView(), D3D12_CLEAR_FLAG_DEPTH | D3D12_CLEAR_FLAG_STENCIL, 1.0f, 0, 0, nullptr);

	// 指定我们想要渲染到的buffer
	mCommandList->OMSetRenderTargets(1, &CurrentBackBufferView(), true, &DepthStencilView());

	// 指示资源使用情况的状态转换
	mCommandList->ResourceBarrier(1, &CD3DX12_RESOURCE_BARRIER::Transition(CurrentBackBuffer(),D3D12_RESOURCE_STATE_RENDER_TARGET, D3D12_RESOURCE_STATE_PRESENT));

	// 完成命令记录
	ThrowIfFailed(mCommandList->Close());

	// 添加Command List 到 Queue 来执行
	ID3D12CommandList* cmdsLists[] = { mCommandList.Get() };
	mCommandQueue->ExecuteCommandLists(_countof(cmdsLists), cmdsLists);

	// 交换 back 和 front buffer
	ThrowIfFailed(mSwapChain->Present(0, 0));
	mCurrBackBuffer = (mCurrBackBuffer + 1) % SwapChainBufferCount;

	// 等到帧命令完成。 这种等待是低效的
	// 目前只为简单而做 之后我们将展示如何组织渲染代码
	FlushCommandQueue();
}

int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE prevInstance,PSTR cmdLine,int showCmd)
{
	// 针对Debug builds 启用 run-time 内存检查
#if defined(DEBUG)|defined(_DEBUG)
	_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif
	try
	{
		InitDirect3DApp theApp(hInstance);
		if (!theApp.Initialize())return 0;
		
		return theApp.Run();
	}
	catch (DxException& e)
	{
		MessageBox(nullptr, e.ToString().c_str(), L"HR Failed", MB_OK);
		return 0;
	}
}



