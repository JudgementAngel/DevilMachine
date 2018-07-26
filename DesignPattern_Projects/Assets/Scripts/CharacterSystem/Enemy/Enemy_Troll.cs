using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Troll : IEnemy {

    protected override void PlayEffect()
    {
        DoPlayEffect("TrollHitEffect");
    }

    protected override void PlaySound()
    {
        
    }
}
