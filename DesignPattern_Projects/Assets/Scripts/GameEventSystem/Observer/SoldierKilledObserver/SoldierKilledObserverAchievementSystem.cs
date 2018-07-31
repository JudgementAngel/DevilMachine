using System;
using System.Collections.Generic;
using System.Text;

class SoldierKilledObserverAchievementSystem : IGameEventObserver
{
    // private EnemyKilledSubject mSubject;

    private AchievementSystem mAchievementSystem;
    public SoldierKilledObserverAchievementSystem(AchievementSystem archievementSystem)
    {
        mAchievementSystem = archievementSystem;
    }
    public override void UpdateInfo()
    {
        mAchievementSystem.AddSoldierKilledCount();
    }

    public override void SetSubject(IGameEventSubject sub)
    {
        // mSubject = sub as EnemyKilledSubject;
    }
}
