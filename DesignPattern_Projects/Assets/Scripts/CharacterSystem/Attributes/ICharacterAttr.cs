using System.Collections;
using System.Collections.Generic;

public class ICharacterAttr
{
    protected CharacterBaseAttr mBaseAttr;

    protected int mCurrentHP;
    protected int mLv; // 等级，只有战士才会升级;

    protected int mDmgDescValue; // 因为减免的伤害是固定的，所以在构造函数中进行初始化

    public ICharacterAttr(IAttrStrategy strategy, int lv, CharacterBaseAttr baseAttr)
    {
        mLv = lv;

        mStrategy = strategy;
        mDmgDescValue = mStrategy.GetDmgDescValue(mLv);
        mCurrentHP = baseAttr.maxHP + mStrategy.GetExtraHPValue(mLv);

        mBaseAttr = baseAttr;
    }

    // 增加的最大血量 抵御的伤害值 暴击增加的伤害 这三个值的实现策略可能会变更
    protected IAttrStrategy mStrategy;

    public int critValue { get { return mStrategy.GetCritDmgValue(mBaseAttr.critRate); } }
    public int currentHP { get { return currentHP; } }
    // public int dmgDescValue { get { return mDmgDescValue; } }

    public void TakeDamage(int damage)
    {
        damage -= mDmgDescValue;
        if (damage < 5) damage = 5;
        mCurrentHP -= damage;
    }
}
