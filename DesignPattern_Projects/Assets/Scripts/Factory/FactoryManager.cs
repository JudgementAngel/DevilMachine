using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public static class FactoryManager
{
    private static IAssetFactory mAssetFactory = null;
    private static ICharacterFactory mSoldierFactory = null;
    private static ICharacterFactory mEnemyFactory = null;
    private static IWeaponFactory mWeaponFactory = null;
    private static IAttrFactory mAttrFactory = null;

    public static IAssetFactory AssetFactory
    {
        get { return mAssetFactory ?? (mAssetFactory = new ResourceAssetFactory()); }
    }

    public static ICharacterFactory SoldierFactory
    {
        get { return mSoldierFactory ?? (mSoldierFactory = new SoldierFactory()); }
    }

    public static ICharacterFactory EnemyFactory
    {
        get { return mEnemyFactory ?? (mEnemyFactory = new EnemyFactory()); }
    }

    public static IWeaponFactory WeaponFactory
    {
        get { return mWeaponFactory ?? (mWeaponFactory = new WeaponFactory()); }
    }

    public static IAttrFactory AttrFactory
    {
        get { return mAttrFactory ?? (mAttrFactory = new AttrFactory()); }
    }
}
