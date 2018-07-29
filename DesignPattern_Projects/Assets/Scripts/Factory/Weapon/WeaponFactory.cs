using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

class WeaponFactory : IWeaponFactory
{
    public IWeapon CreateWeapon(WeaponType weaponType)
    {
        WeaponBaseAttr baseAttr = FactoryManager.AttrFactory.GetWeaponBaseAttr(weaponType);
        GameObject weaponGO = FactoryManager.AssetFactory.LoadWeapon(baseAttr.assetName);

        IWeapon weapon = null;
        switch (weaponType)
        {
            case WeaponType.Gun:
                weapon = new WeaponGun(baseAttr, weaponGO);
                break;
            case WeaponType.Rifle:
                weapon = new WeaponRifle(baseAttr, weaponGO);
                break;
            case WeaponType.Rocket:
                weapon = new WeaponRocket(baseAttr, weaponGO);
                break;
        }

        return weapon;
    }
}
