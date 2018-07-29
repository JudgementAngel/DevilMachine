using System;
using System.Collections.Generic;
using System.Text;

/// <summary>
/// �������Ĳ���
/// </summary>
public interface IEnergyCostStrategy
{
     int GetCampUpgradeCost(SoldierType st, int lv);
     int GetWeaponUpgradeCost(WeaponType wt);
     int GetSoldierTrainCost(SoldierType st,int lv);
}
