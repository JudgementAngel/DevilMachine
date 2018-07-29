using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

class SoldierEnergyCostStrategy : IEnergyCostStrategy
{
    public int GetCampUpgradeCost(SoldierType st, int lv)
    {
        int energy = 0;
        switch (st)
        {
            case SoldierType.Rookie:
                energy = 60;
                break;
            case SoldierType.Sergeant:
                energy = 65;
                break;
            case SoldierType.Captain:
                energy = 70;
                break;
            default:
                Debug.LogError("无法获取" + st + "类型兵营升级所消耗的能量值");
                break;
        }

        energy += (lv - 1) * 2;

        if (energy > 100) energy = 100;
        return energy;
    }

    public int GetWeaponUpgradeCost(WeaponType wt)
    {
        int energy = 0;
        switch (wt)
        {
            case WeaponType.Gun:
                energy = 30;
                break;
            case WeaponType.Rifle:
                energy = 40;
                break;
            case WeaponType.Rocket:
                energy = 50;
                break;
            default:
                Debug.LogError("无法获取" + wt + "类型武器升级所消耗的能量值");
                break;
        }

        return energy;

    }

    public int GetSoldierTrainCost(SoldierType st, int lv)
    {
        int energy = 0;
        switch (st)
        {
            case SoldierType.Rookie:
                energy = 10;
                break;
            case SoldierType.Sergeant:
                energy = 15;
                break;
            case SoldierType.Captain:
                energy = 20;
                break;
            default:
                Debug.LogError("无法获取" + st + "类型兵营升级所消耗的能量值");
                break;
        }

        energy += (lv - 1) * 2;

        
        return energy;
    }
}
