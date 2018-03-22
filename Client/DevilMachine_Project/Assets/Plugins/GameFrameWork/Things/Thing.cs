using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Thing 
{
    protected string _mName;
    public Thing(string name)
    {
        _mName = name;
    }
    public virtual void OnGenerate() { }
    public virtual void OnUpdate() { }
    public virtual void OnDestory() { }
}
