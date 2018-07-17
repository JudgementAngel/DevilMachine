using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponGun : IWeapon
{
    protected override void PlauSound()
    {
        DoPlaySound("GunShot");
    }

    protected override void PlayBulletEffect(Vector3 targetPosition)
    {
        DoPlayBulletEffect(0.05f, targetPosition);
    }

    protected override void SetEffectDisplayTime()
    {
        mEffectDisplayTime = 0.2f;
    }
}
