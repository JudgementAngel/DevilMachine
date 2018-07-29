using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class CampOnClick : MonoBehaviour
{
    private ICamp mCamp;

    public ICamp camp
    {
       
        set
        {
            mCamp = value;
        }
    }

    void Start()
    {
        
    }
    /// <summary>
    /// Unity自带实现点击事件
    /// </summary>
    void OnMouseUpAsButton()
    {
        GameFacade.Instance.ShowCampInfo(mCamp);
    }
}
