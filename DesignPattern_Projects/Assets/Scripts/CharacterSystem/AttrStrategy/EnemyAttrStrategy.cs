using System;
using System.Collections.Generic;

using System.Text;


class EnemyAttrStrategy : IAttrStrategy
{
    public int GetCritDmgValue(float critRate)
    {
        if (UnityEngine.Random.Range(0, 1f) < critRate)
            return (int)(10 * UnityEngine.Random.Range(.5f, 1f));
        return 0;
    }

    public int GetDmgDescValue(int Lv)
    {
        return 0;
    }

    public int GetExtraHPValue(int Lv)
    {
        return 0;
    }
}

