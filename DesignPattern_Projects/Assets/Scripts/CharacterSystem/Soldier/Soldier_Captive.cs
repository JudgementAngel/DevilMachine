using System;
using System.Collections.Generic;
using System.Text;

class Soldier_Captive : ISoldier
{
    private IEnemy mEnemy;
    public Soldier_Captive(IEnemy enemy)
    {
        mEnemy = enemy;
        // TODO
        ICharacterAttr attr = new SoldierAttr(enemy.attr.strategy,1,enemy.attr.baseAttr);
        this.attr = attr;

        this.gameObject = mEnemy.gameObject;
        this.weapon = mEnemy.weapon;
    }

    public override void PlaySound()
    {
        // DoNothing
    }

    public override void PlayEffect()
    {
        mEnemy.PlayEffect();
    }
}
