using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soldier_Rookie : ISoldier {
    public override void PlayEffect()
    {
        DoPlayEffect("RookieDeadEffect");
    }

    public override void PlaySound()
    {
        DoPlaySound("RookieDeath");
    }
}
