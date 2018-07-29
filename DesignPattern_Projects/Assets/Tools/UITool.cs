using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class UITool
{
    public static T FindChild<T>(GameObject parent, string childName)
    {
        GameObject uiGO = UnityTool.FindChild(parent, childName);
        if (uiGO == null)
        {
            Debug.LogError("����Ϸ����"+parent+"������Ҳ���" + childName);
            return default(T);
        }
        return uiGO.GetComponent<T>();
    }
}

