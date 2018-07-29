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
            Debug.LogError("在游戏物体"+parent+"下面查找不到" + childName);
            return default(T);
        }
        return uiGO.GetComponent<T>();
    }
}

