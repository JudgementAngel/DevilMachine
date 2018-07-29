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
    /// Unity�Դ�ʵ�ֵ���¼�
    /// </summary>
    void OnMouseUpAsButton()
    {
        GameFacade.Instance.ShowCampInfo(mCamp);
    }
}
