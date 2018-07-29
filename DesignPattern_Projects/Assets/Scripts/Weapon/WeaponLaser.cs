using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponLaser : IWeapon
{
    public WeaponLaser(WeaponBaseAttr baseAttr, GameObject gameObject) : base(baseAttr, gameObject)
    {
    }

    protected override void PlauSound()
    {
        DoPlaySound("LaserShot");
    }
    protected override void PlayBulletEffect(Vector3 targetPosition)
    {
        DoPlayBulletEffect(0.1f,targetPosition);
    }
    protected override void SetEffectDisplayTime()
    {
        mEffectDisplayTime = 0.25f;
    }

   
}
