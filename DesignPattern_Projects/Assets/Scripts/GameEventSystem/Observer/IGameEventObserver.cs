using System;
using System.Collections.Generic;
using System.Text;

public abstract class IGameEventObserver
{
    public abstract void UpdateInfo();
    public abstract void SetSubject(IGameEventSubject sub);
}
