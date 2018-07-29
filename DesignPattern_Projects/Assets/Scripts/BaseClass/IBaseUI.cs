using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class IBaseUI
{
    public GameObject mRootUI;
    public virtual void Init() { }
    public virtual void Update() { }
    public virtual void Release() { }

    protected void Show() { if (mRootUI != null) mRootUI.SetActive(true); }
    protected void Hide() { if (mRootUI != null) mRootUI.SetActive(false); }
}
