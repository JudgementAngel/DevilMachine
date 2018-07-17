using System;
using System.Collections.Generic;
using System.Text;

/// <summary>
/// 用于模拟接口的类，需要在接口中添加一些字段
/// </summary>
public class ISceneState
{ 
    private string mSceneName;
    public SceneStateController mController;

    public string SceneName
    {
        get { return mSceneName; }
    }

    public ISceneState(string sceneName,SceneStateController controller)
    {
        mSceneName = sceneName;
        mController = controller;
    }

    public virtual void StateStart() { }
    public virtual void StateUpdate() { }
    public virtual void StateEnd() { }
}

