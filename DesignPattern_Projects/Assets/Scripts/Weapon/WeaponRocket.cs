using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class WeaponRocket : IWeapon
{
    protected override void PlauSound()
    {
        DoPlaySound("RocketShot");
    }
    protected override void PlayBulletEffect(Vector3 targetPosition)
    {
        DoPlayBulletEffect(0.3f,targetPosition);
    }

    protected override void SetEffectDisplayTime()
    {
        mEffectDisplayTime = 0.4f;
    }
}
