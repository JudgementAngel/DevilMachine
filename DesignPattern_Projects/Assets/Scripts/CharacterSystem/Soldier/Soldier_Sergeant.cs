using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soldier_Sergeant : ISoldier
{

    protected override void PlayEffect()
    {
        DoPlayEffect("SergeantDeadEffect");
    }
    protected override void PlaySound()
    {
        DoPlaySound("SergeantDeath");
    }
}
