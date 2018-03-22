using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class T_Unit : Thing
{
    protected GameObject _mGameObject;
    protected string _mPath;
    protected string _mName;
    public GameObject mGameObject
    {
        get
        {
            if (_mGameObject == null)
            {
                _mGameObject = PoolManager.Instance.LoadGameObject(_mPath, _mName);
            }
            return _mGameObject;
        }
    }

    public T_Unit(string path,string name):base(name)
    {
        _mPath = path;
    }

}
