using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Ogre : IEnemy {
    public override void PlayEffect()
    {
        DoPlayEffect("OgreHitEffect");
    }

    public override void PlaySound()
    {
        
    }
}
