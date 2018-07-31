using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AchievementSystem : IGameSystem
{
    private int mEnemyKilledCount = 0;
    private int mSoldierKilledCount = 0;
    private int mMaxStageLv = 1;

    public override void Init()
    {
        base.Init();
        mFacade.RegisterObserver(GameEventType.EnemyKilled, new EnemyKilledObserverAchievementSystem(this));
        mFacade.RegisterObserver(GameEventType.SoldierKilled, new SoldierKilledObserverAchievementSystem(this));
        mFacade.RegisterObserver(GameEventType.NewStage, new NewStageObserverAchievementSystem(this));
    }

    public void AddEnemyKilledCount(int number = 1)
    {
        mEnemyKilledCount += number;
        //Debug.Log("EKC" + mEnemyKilledCount);
    }

    public void AddSoldierKilledCount(int number = 1)
    {
        mSoldierKilledCount += number;
        //Debug.Log("SKC" + mSoldierKilledCount);
    }

    public void SetMaxStageLv(int stageLv)
    {
        mMaxStageLv = Mathf.Max(mMaxStageLv, stageLv);
        //Debug.Log("MaxS" + mMaxStageLv);
    }

    public AchievementMemento CreateMemento()
    {
        AchievementMemento memento = new AchievementMemento();
        memento.enemyKilledCount = mEnemyKilledCount;
        memento.soldierKilledCount = mSoldierKilledCount;
        memento.maxStageLv = mMaxStageLv;
        return memento;
    }

    public void SetMemento(AchievementMemento memento)
    {
        mEnemyKilledCount = memento.enemyKilledCount;
        mSoldierKilledCount = memento.soldierKilledCount;
        mMaxStageLv = memento.maxStageLv;
    }


}
