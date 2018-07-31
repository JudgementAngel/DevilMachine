using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class IGameSystem
{
    protected GameFacade mFacade;
    public virtual void Init(){ mFacade = GameFacade.Instance; }
    public virtual void Update() { }
    public virtual void Release() { }
}
