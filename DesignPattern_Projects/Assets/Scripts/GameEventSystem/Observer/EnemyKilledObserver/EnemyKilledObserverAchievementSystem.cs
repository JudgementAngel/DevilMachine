using System;
using System.Collections.Generic;
using System.Text;

class EnemyKilledObserverAchievementSystem : IGameEventObserver
{
    // private EnemyKilledSubject mSubject;

    private AchievementSystem mAchievementSystem;
    public EnemyKilledObserverAchievementSystem(AchievementSystem archievementSystem)
    {
        mAchievementSystem = archievementSystem;
    }
    public override void UpdateInfo()
    {
        mAchievementSystem.AddEnemyKilledCount();
    }

    public override void SetSubject(IGameEventSubject sub)
    {
        // mSubject = sub as EnemyKilledSubject;
    }
}
