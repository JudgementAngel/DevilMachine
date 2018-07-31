using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class TrainSoldierCommand : ITrainCommand
{
    private SoldierType mSoldierType;
    private WeaponType mWeaponType;
    private Vector3 mPosition;
    private int mLv;

    public TrainSoldierCommand(SoldierType st, WeaponType wt, Vector3 pos, int lv)
    {
        mSoldierType = st;
        mWeaponType = wt;
        mPosition = pos;
        mLv = lv;
    }

    public override void Execute()
    {
        switch (mSoldierType)
        {
            case SoldierType.Rookie:
                FactoryManager.SoldierFactory.CreateCharacter<Soldier_Rookie>(mWeaponType, mPosition, mLv);
                break;
            case SoldierType.Sergeant:
                FactoryManager.SoldierFactory.CreateCharacter<Soldier_Sergeant>(mWeaponType, mPosition, mLv);
                break;
            case SoldierType.Captain:
                FactoryManager.SoldierFactory.CreateCharacter<Soldier_Captain>(mWeaponType, mPosition, mLv);
                break;
            default:
                Debug.LogError("无法根据SoldierType:"+mSoldierType+"创建角色");
                break;
        }
    }
}
