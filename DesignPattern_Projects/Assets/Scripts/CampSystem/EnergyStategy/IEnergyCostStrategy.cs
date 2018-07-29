using System;
using System.Collections.Generic;
using System.Text;

/// <summary>
/// 能量消耗策略
/// </summary>
public interface IEnergyCostStrategy
{
     int GetCampUpgradeCost(SoldierType st, int lv);
     int GetWeaponUpgradeCost(WeaponType wt);
     int GetSoldierTrainCost(SoldierType st,int lv);
}
