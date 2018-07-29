using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoldierAttr : ICharacterAttr
{
    public SoldierAttr(IAttrStrategy strategy, int lv, CharacterBaseAttr baseAttr) : base(strategy, lv, baseAttr)
    {
    }
}
