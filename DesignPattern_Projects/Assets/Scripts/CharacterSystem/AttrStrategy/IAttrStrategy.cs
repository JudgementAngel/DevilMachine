using System;
using System.Collections.Generic;
using System.Text;

public interface IAttrStrategy
{
    int GetExtraHPValue(int Lv);
    int GetDmgDescValue(int Lv);
    int GetCritDmgValue(float critRate);
}
