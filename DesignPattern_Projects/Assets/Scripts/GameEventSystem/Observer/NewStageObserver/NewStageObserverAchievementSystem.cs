using System;
using System.Collections.Generic;
using System.Text;

class NewStageObserverAchievementSystem:IGameEventObserver
{
    private NewStageSubject mSubject;
    private AchievementSystem mAchievementSystem;
    public NewStageObserverAchievementSystem(AchievementSystem archievementSystem)
    {
        mAchievementSystem = archievementSystem;
    }
    public override void UpdateInfo()
    {
        mAchievementSystem.SetMaxStageLv(mSubject.stageCount);
    }

    public override void SetSubject(IGameEventSubject sub)
    {
        mSubject = sub as NewStageSubject;
    }
}
