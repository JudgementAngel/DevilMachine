using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class CaptiveCamp:ICamp
{
    private WeaponType mWeaponType = WeaponType.Gun;
    private EnemyType mEnemyType;
    public CaptiveCamp(GameObject gameObject, string name, string icon, EnemyType enemyType, Vector3 position, float trainTime) : base(gameObject, name, icon, SoldierType.Captive, position, trainTime)
    {
        energyCostStrategy = new SoldierEnergyCostStrategy();
        mEnemyType = enemyType;
        UpdateEnergyCost();
    }

    public override int lv
    {
        get { return 1; }
    }

    public override WeaponType weaponType
    {
        get { return mWeaponType; }
    }

    public override void Train()
    {
        TrainCaptiveCommand cmd = new TrainCaptiveCommand(mEnemyType,mWeaponType,mPosition);
        mCommands.Add(cmd);
    }

    public override void UpdateEnergyCost()
    {
        mEnergyCostTrain = energyCostStrategy.GetSoldierTrainCost(SoldierType.Captive, 1);
    }

    public override void UpgradeCamps()
    {
        return;
    }

    public override void UpgradeWeapon()
    {
        return;
    }

    public override int energyCostCampUpgrade
    {
        get { return 0; }
    }

    public override int energyCostWeaponUpgrade
    {
        get { return 0; }
    }

    public override int energyCostTrain
    {
        get { return mEnergyCostTrain; }
    }
}
