using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Ogre : IEnemy {

    protected override void PlayEffect()
    {
        DoPlayEffect("OgreHitEffect");
    }

    protected override void PlaySound()
    {
        
    }
}
