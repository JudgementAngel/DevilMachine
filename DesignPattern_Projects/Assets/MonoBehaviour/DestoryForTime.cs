using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestoryForTime : MonoBehaviour
{
    public float time = 1;
    // Use this for initialization
    void Start()
    {
        Invoke("Destory",time);
    }

    void Destory()
    {
        GameObject.DestroyImmediate(this.gameObject);
    }

    // Update is called once per frame
    void Update()
    {

    }
}
