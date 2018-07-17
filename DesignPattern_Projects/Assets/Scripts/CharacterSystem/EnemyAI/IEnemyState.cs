using System;
using System.Collections.Generic;
using System.Text;

public enum EnemyTransition
{
    NullTransition = 0,
    CanAttack,
    LostSoldier
}

public enum EnemyStateID
{
    NullState = 0,
    Chase,
    Attack
}


public abstract class IEnemyState
{
    protected Dictionary<EnemyTransition, EnemyStateID> mMap = new Dictionary<EnemyTransition, EnemyStateID>();
    protected EnemyStateID mStateID;
    public EnemyStateID stateID { get { return mStateID; } }
    protected ICharacter mCharacter;
    protected EnemyFSMSystem mFSM;

    public IEnemyState(EnemyFSMSystem fsm, ICharacter character)
    {
        mFSM = fsm;
        mCharacter = character;
    }

    public void AddTransiiton(EnemyTransition trans, EnemyStateID id)
    {
        if (trans == EnemyTransition.NullTransition)
        {
            BaseLog.LogError("EnemyTransition Error:trans 不能为空"); return;
        }
        if (id == EnemyStateID.NullState)
        {
            BaseLog.LogError("EnemyTransition Error:id状态 不能为空"); return;
        }
        if (mMap.ContainsKey(trans))
        {
            BaseLog.LogError("EnemyTransition Error: " + trans + "已经添加上了"); return;
        }

        mMap.Add(trans, id);
    }

    public void DeleteTransition(EnemyTransition trans)
    {
        if (mMap.ContainsKey(trans) == false)
        {
            BaseLog.LogError("删除转换条件的时候，转换条件[" + trans + "]不存在"); return;
        }
        mMap.Remove(trans);
    }

    public EnemyStateID GetOutPutState(EnemyTransition trans)
    {
        if (mMap.ContainsKey(trans) == false)
        {
            BaseLog.LogError("转换条件[" + trans + "]不存在"); return EnemyStateID.NullState;
        }
        else
        {
            return mMap[trans];
        }
    }

    public virtual void DoBeforeEntering() { }
    public virtual void DoBeforeLeaving() { }

    public abstract void Reason(List<ICharacter> targets); // 用于判断当前状态是否转化到别的状态
    public abstract void Act(List<ICharacter> targets); // 当前状态每帧执行的事情

}
