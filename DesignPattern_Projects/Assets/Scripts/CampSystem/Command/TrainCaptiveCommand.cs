using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class TrainCaptiveCommand :ITrainCommand
{
    public EnemyType mEnemyType;
    private WeaponType mWeaponType;
    private Vector3 mPosition;
    private int mLv;

    public TrainCaptiveCommand(EnemyType et, WeaponType wt, Vector3 pos, int lv = 1)
    {
        mEnemyType = et;
        mWeaponType = wt;
        mPosition = pos;
        mLv = lv;
    }

    public override void Execute()
    {
        IEnemy enemy = null;

        switch (mEnemyType)
        {
            case EnemyType.Elf:
                enemy = FactoryManager.EnemyFactory.CreateCharacter<Enemy_Elf>(mWeaponType, mPosition) as IEnemy;
                break;
            case EnemyType.Ogre:
                enemy = FactoryManager.EnemyFactory.CreateCharacter<Enemy_Ogre>(mWeaponType, mPosition) as IEnemy;
                break;
            case EnemyType.Troll:
                enemy = FactoryManager.EnemyFactory.CreateCharacter<Enemy_Troll>(mWeaponType, mPosition) as IEnemy;
                break;
            default:
                Debug.Log("无法创建俘兵："+mEnemyType);
                break;
        }
        GameFacade.Instance.RemoveEnemy(enemy);
        Soldier_Captive captive = new Soldier_Captive(enemy);
        GameFacade.Instance.AddSoldier(captive);
    }
}
