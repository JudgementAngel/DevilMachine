using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAttr : ICharacterAttr
{
    public EnemyAttr(IAttrStrategy strategy, string name, int maxHP, float moveSpeed, string iconSprite, string prefanName) : base(strategy,name,maxHP,moveSpeed,iconSprite,prefanName)
    {
        
    }
}
