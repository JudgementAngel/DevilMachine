using System;
using System.Collections.Generic;
using System.Text;

public abstract class IStageHandler
{
    protected int mLv;
    protected IStageHandler mNextHandler;
    protected StageSystem mStageSystem;
    private int mCountToFinished;

    public IStageHandler(StageSystem stageSystem,int lv,int countToFinished)
    {
        mLv = lv;
        mCountToFinished = countToFinished;
        mStageSystem = stageSystem;
    }

    public IStageHandler SetNextHandler(IStageHandler handler)
    {
        mNextHandler = handler;
        return mNextHandler;
    }

    public void Handle(int level)
    {
        if (level == mLv)
        {
            UpdateStage();
            CheckIsFinished(); // 检查关卡是否结束
        }
        else mNextHandler.Handle(level);
    }

    private void CheckIsFinished()
    {
        if (mStageSystem.GetCountOfEnemyKilled() >= mCountToFinished)
        {
            mStageSystem.EnterNextStage();
        }
    }

    protected virtual void UpdateStage(){}
}
