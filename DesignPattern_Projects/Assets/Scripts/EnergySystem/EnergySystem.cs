using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnergySystem : IGameSystem
{
    public const float MAX_ENERGY = 100;
    private float mNowEnergy = MAX_ENERGY;

    private float mRecoverSpeed = 3;

    public override void Init()
    {
        base.Init();
    }

    public override void Update()
    {
        base.Update();
        mFacade.UpdateEnergySlider((int)mNowEnergy, (int)MAX_ENERGY);
        if (mNowEnergy >= MAX_ENERGY) return;
        mNowEnergy += mRecoverSpeed * Time.deltaTime;
        mNowEnergy = Mathf.Min(mNowEnergy,MAX_ENERGY);

        
    }

    public bool TakeEnergy(int value)
    {
        
        if (mNowEnergy >= value)
        {
            mNowEnergy -= value;

            return true;
        }
        return false;
    }

    public void RecycleEnergy(int value)
    {
        mNowEnergy += value;
        mNowEnergy = Mathf.Min(mNowEnergy,MAX_ENERGY);

    }
}
