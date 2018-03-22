using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ABManager
{
    private static ABManager _instance;
    public static ABManager Instance
    {
        get
        {
            if (_instance == null)
                _instance = new ABManager();
            return _instance;
        }
    }

    private ABManager()
    {

    }

    public GameObject LoadFromPath(string path,string name)
    {
        // AssetBundle ab = AssetBundle.LoadFromFile(path);
        // return ab.LoadAsset<GameObject>(name);
        GameObject go = (GameObject)AssetDatabase.LoadAssetAtPath<GameObject>(path);
        Debug.Log(go.name);
        return go;
    }
    
}
