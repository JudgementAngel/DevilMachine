using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soldier_Captain : ISoldier
{
    public override void PlayEffect()
    {
        DoPlayEffect("CaptainDeadEffect");
    }

    public override void PlaySound()
    {
        DoPlaySound("CaptainDeath");
    }
}
