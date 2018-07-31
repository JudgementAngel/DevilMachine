using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class NormalStageHandler:IStageHandler
{
    private EnemyType mEnemyType;
    private WeaponType mWeaponType;
    private int mCount;
    private Vector3 mPosition;

    private float mSpawnTime = 3;
    private float mSpawnTimer = 0;
    private int mCountSpawned = 0;

    public NormalStageHandler(StageSystem stageSystem, int lv, int countToFinished, EnemyType et,WeaponType wt,int count,Vector3 pos) : base(stageSystem,lv, countToFinished)
    {
        mEnemyType = et;
        mWeaponType = wt;
        mCount = count;
        mPosition = pos;
        mSpawnTimer = mSpawnTime;
    }

    protected override void UpdateStage()
    {
        base.UpdateStage();
        if (mCountSpawned < mCount)
        {
            mSpawnTimer -= Time.deltaTime;
            if (mSpawnTimer <= 0)
            {
                SpawnEnemy();
                mSpawnTimer = mSpawnTime;
            }
        }
    }

    private void SpawnEnemy()
    {
        mCountSpawned++;
        switch (mEnemyType)
        {
            case EnemyType.Elf:
                FactoryManager.EnemyFactory.CreateCharacter<Enemy_Elf>(mWeaponType, mPosition);
                break;
            case EnemyType.Ogre:
                FactoryManager.EnemyFactory.CreateCharacter<Enemy_Ogre>(mWeaponType, mPosition);
                break;
            case EnemyType.Troll:
                FactoryManager.EnemyFactory.CreateCharacter<Enemy_Troll>(mWeaponType, mPosition);
                break;
            default:
                Debug.LogError("无法生成"+ mEnemyType +"类型的敌人");
                break;
        }   
    }
}
