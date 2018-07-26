using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Soldier_Captain : ISoldier
{
    protected override void PlayEffect()
    {
        DoPlayEffect("CaptainDeadEffect");
    }
    protected override void PlaySound()
    {
        DoPlaySound("CaptainDeath");
    }
}
