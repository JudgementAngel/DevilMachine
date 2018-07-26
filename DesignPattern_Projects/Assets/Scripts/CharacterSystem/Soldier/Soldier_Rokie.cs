using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soldier_Rokie : ISoldier {
    protected override void PlayEffect()
    {
        DoPlayEffect("RokieDeadEffect");
    }
    protected override void PlaySound()
    {
        DoPlaySound("RokieDeath");
    }
}
