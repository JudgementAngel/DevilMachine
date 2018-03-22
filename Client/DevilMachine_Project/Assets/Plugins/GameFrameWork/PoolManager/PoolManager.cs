using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolManager
{
    private static PoolManager _instance;
    public static PoolManager Instance
    {
        get
        {
            if (_instance == null)
                _instance = new PoolManager();
            return _instance;
        }
    }

    private PoolManager()
    {

    }

    public GameObject LoadGameObject(string path,string name)
    {
        return ABManager.Instance.LoadFromPath(path, name);
    }

}
