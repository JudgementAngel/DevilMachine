using System;
using System.Collections.Generic;
using System.Text;

public abstract class IGameEventSubject
{
    private List<IGameEventObserver> mObservers = new List<IGameEventObserver>();

    public void RegisterObserver(IGameEventObserver ob)
    {
        mObservers.Add(ob);
    }

    public void RemoveObserver(IGameEventObserver ob)
    {
        mObservers.Remove(ob);
    }

    public virtual void Notify()
    {
        foreach (IGameEventObserver observer in mObservers)
        {
            observer.UpdateInfo();
        }
    }


}
