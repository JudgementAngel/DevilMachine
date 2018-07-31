using System;
using System.Collections.Generic;
using System.Text;

public class SoldierKilledSubject:IGameEventSubject
{
    private int mKilledCount = 0;

    public int killCount { get { return mKilledCount; } }

    public override void Notify()
    {
        mKilledCount++;
        base.Notify();
    }
}
