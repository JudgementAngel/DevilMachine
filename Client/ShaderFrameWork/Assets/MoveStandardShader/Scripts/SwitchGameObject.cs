using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SwitchGameObject : MonoBehaviour {
    public GameObject go1;
    public GameObject go2;
    private bool temp = false;
    // Use this for initialization
    void Start ()
    {
		
	}
	
	// Update is called once per frame
	void Update ()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            go1.SetActive(temp);
            go2.SetActive(!temp);
            temp = !temp;
        }	
	}

}
