using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Ogre : IEnemy {
    protected override void PlayEffect()
    {
        DOPlayEffect("OgreHitEffect");
    }
}
