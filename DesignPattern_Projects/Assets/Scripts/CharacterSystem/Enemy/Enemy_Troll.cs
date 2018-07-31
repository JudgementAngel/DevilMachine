using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Troll : IEnemy {
    public override void PlayEffect()
    {
        DoPlayEffect("TrollHitEffect");
    }

    public override void PlaySound()
    {
        
    }
}
