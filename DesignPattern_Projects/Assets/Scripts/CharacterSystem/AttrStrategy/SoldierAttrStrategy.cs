using System;
using System.Collections.Generic;

using System.Text;


class SoldierAttrStrategy : IAttrStrategy
{
    public int GetCritDmgValue(float critRate)
    {
        return 0;
    }

    public int GetDmgDescValue(int Lv)
    {
        return (Lv - 1) * 5;
    }

    public int GetExtraHPValue(int Lv)
    {
        return (Lv - 1) * 10;
    }
}

