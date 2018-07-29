using System;
using System.Collections.Generic;
using System.Text;

public class EnemyFSMSystem
{
    private List<IEnemyState> mStates;
    private IEnemyState mCurrentState;
    public IEnemyState CurrentState { get { return mCurrentState; } }

    public void AddState(params IEnemyState[] states)
    {
        foreach (IEnemyState state in states)
        {
            AddState(state);
        }

    }
    public void AddState(IEnemyState state)
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
            mCurrentState.DoBeforeEntering();
            return;
        }
        foreach (IEnemyState s in mStates)
        {
            if (s.stateID == state.stateID)
            {
                UnityEngine.Debug.LogError("要添加的状态ID[" + s.stateID + "]已经添加");
                return;
            }
        }
        mStates.Add(state);
    }

    public void DeleteState(EnemyStateID stateID)
    {
        if (stateID == EnemyStateID.NullState)
        {
            UnityEngine.Debug.LogError("要删除的状态ID为空" + stateID);
            return;
        }
        foreach (IEnemyState s in mStates)
        {
            if (s.stateID == stateID)
            {
                mStates.Remove(s);
                return;
            }
        }
        UnityEngine.Debug.LogError("要删除的StatedID[" + stateID + "]不存在集合中");
    }    // 一般不需要删除状态;
    public void PerformTransition(EnemyTransition trans)
    {
        if (trans == EnemyTransition.NullTransition)
        {
            UnityEngine.Debug.LogError("要转换的条件为空:" + trans);
            return;
        }
        EnemyStateID nextStateID = mCurrentState.GetOutPutState(trans);
        if (nextStateID == EnemyStateID.NullState)
        {
            UnityEngine.Debug.LogError("在转换条件 [" + trans + "] 下，没有对应的转换状态");
            return;
        }

        foreach (IEnemyState s in mStates)
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
