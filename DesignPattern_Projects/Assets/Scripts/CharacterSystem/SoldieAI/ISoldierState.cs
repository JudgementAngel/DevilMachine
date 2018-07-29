using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public enum SoldierTransition
{
    NullTransition = 0,
    SeeEnemy,
    NoEnemy,
    CanAttack
}

public enum SoldierStateID
{
    NullState = 0,
    Idle,
    Chase,
    Attack
}

public abstract class  ISoldierState
{
    protected Dictionary<SoldierTransition,SoldierStateID> mMap = new Dictionary<SoldierTransition, SoldierStateID>();
    protected SoldierStateID mStateID;
    public SoldierStateID stateID { get { return mStateID; } }
    protected ICharacter mCharacter;
    protected SoldierFSMSystem mFSM;

    public ISoldierState(SoldierFSMSystem fsm,ICharacter character)
    {
        mFSM = fsm;
        mCharacter = character;
    }

    public void AddTransiiton(SoldierTransition trans,SoldierStateID id)
    {
        if (trans == SoldierTransition.NullTransition)
        {
            Debug.LogError("SoldierTransition Error:trans 不能为空");return;
        }
        if (id == SoldierStateID.NullState)
        {
            Debug.LogError("SoldierTransition Error:id状态 不能为空"); return;
        }
        if (mMap.ContainsKey(trans))
        {
            Debug.LogError("SoldierTransition Error: " + trans+"已经添加上了"); return;
        }

        mMap.Add(trans,id);
    }

    public void DeleteTransition(SoldierTransition trans)
    {
        if (mMap.ContainsKey(trans) == false)
        {
            Debug.LogError("删除转换条件的时候，转换条件["+trans+"]不存在"); return;
        }
        mMap.Remove(trans);
    }

    public SoldierStateID GetOutPutState(SoldierTransition trans)
    {
        if (mMap.ContainsKey(trans) == false)
        {
            Debug.LogError("转换条件[" + trans + "]不存在"); return SoldierStateID.NullState; 
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
