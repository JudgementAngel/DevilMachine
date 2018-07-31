using System;
using System.Collections.Generic;
using System.Text;

public class EnemyKilledObserverStageSystem:IGameEventObserver
{
    private EnemyKilledSubject mSubject;
    private StageSystem mStageSystem;
    public EnemyKilledObserverStageSystem(StageSystem ss)
    {
        mStageSystem = ss;
    }

    public override void UpdateInfo()
    {
        mStageSystem.countOfEnemyKilled = mSubject.killCount;
    }

    public override void SetSubject(IGameEventSubject sub)
    {
        mSubject = sub as EnemyKilledSubject;
    }
}
