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
            BaseLog.LogError("Ҫ��ӵ�״̬Ϊ��");
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
                BaseLog.LogError("Ҫ��ӵ�״̬ID[" + s.stateID + "]�Ѿ����");
                return;
            }
        }
        mStates.Add(state);
    }
    public void DeleteState(EnemyStateID stateID)
    {
        if (stateID == EnemyStateID.NullState)
        {
            BaseLog.LogError("Ҫɾ����״̬IDΪ��" + stateID);
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
        BaseLog.LogError("Ҫɾ����StatedID[" + stateID + "]�����ڼ�����");
    }    // һ�㲻��Ҫɾ��״̬;
    public void PerformTransition(EnemyTransition trans)
    {
        if (trans == EnemyTransition.NullTransition)
        {
            BaseLog.LogError("Ҫת��������Ϊ��:" + trans);
            return;
        }
        EnemyStateID nextStateID = mCurrentState.GetOutPutState(trans);
        if (nextStateID == EnemyStateID.NullState)
        {
            BaseLog.LogError("��ת������ [" + trans + "] �£�û�ж�Ӧ��ת��״̬");
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
