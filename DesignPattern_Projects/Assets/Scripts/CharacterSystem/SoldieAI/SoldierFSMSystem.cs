using System;
using System.Collections.Generic;
using System.Text;

public class SoldierFSMSystem
{
    private List<ISoldierState> mStates = new List<ISoldierState>();
    private ISoldierState mCurrentState;
    public ISoldierState CurrentState { get { return mCurrentState; } }

    public void AddState(params ISoldierState[] states)
    {
        foreach (ISoldierState state in states)
        {
            AddState(state);
        }
        
    }
    public void AddState(ISoldierState state)
    {
        if (state == null)
        {
            UnityEngine.Debug.LogError("要添加的状态为空");
            return;
        }

        if (mStates.Count == 0)
        {
            mStates.Add(state);
            mCurrentState = state;
            return;
        }
        foreach (ISoldierState s in mStates)
        {
            if (s.stateID == state.stateID)
            {
                UnityEngine.Debug.LogError("要添加的状态ID["+s.stateID+"]已经添加");
                return;
            }
        }
        mStates.Add(state);
    }
    public void DeleteState(SoldierStateID stateID)
    {
        if (stateID == SoldierStateID.NullState)
        {
            UnityEngine.Debug.LogError("要删除的状态ID为空"+stateID);
            return;
        }
        foreach (ISoldierState s in mStates)
        {
            if (s.stateID == stateID)
            {
                mStates.Remove(s);
                return;
            }
        }
        UnityEngine.Debug.LogError("要删除的StatedID["+stateID+"]不存在集合中");
    }    // 一般不需要删除状态;
    public void PerformTransition(SoldierTransition trans)
    {
        if (trans == SoldierTransition.NullTransition)
        {
            UnityEngine.Debug.LogError("要转换的条件为空:" + trans); 
            return;
        }
        SoldierStateID nextStateID = mCurrentState.GetOutPutState(trans);
        if (nextStateID == SoldierStateID.NullState)
        {
            UnityEngine.Debug.LogError("在转换条件 ["+trans+"] 下，没有对应的转换状态");
            return;
        }

        foreach (ISoldierState s in mStates)
        {
            if (s.stateID == nextStateID)
            {
                mCurrentState.DoBeforeLeaving();
                mCurrentState = s;
                mCurrentState.DoBeforeEntering();
            }
        }
    }
}
