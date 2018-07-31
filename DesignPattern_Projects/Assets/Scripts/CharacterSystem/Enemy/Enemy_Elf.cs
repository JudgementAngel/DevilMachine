using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Elf : IEnemy {
    public override void PlayEffect()
    {
        DoPlayEffect("ElfHitEffect");
    }

    public override void PlaySound()
    {
        
    }
}
