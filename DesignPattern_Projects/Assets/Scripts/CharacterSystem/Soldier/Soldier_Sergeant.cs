using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soldier_Sergeant : ISoldier
{
    public override void PlayEffect()
    {
        DoPlayEffect("SergeantDeadEffect");
    }

    public override void PlaySound()
    {
        DoPlaySound("SergeantDeath");
    }
}
