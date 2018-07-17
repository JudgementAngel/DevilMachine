using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy_Elf : IEnemy {
    protected override void PlayEffect()
    {
        DOPlayEffect("ElfHitEffect");
    }
}
