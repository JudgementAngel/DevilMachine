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
            UnityEngine.Debug.LogError("Ҫ��ӵ�״̬Ϊ��");
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
                UnityEngine.Debug.LogError("Ҫ��ӵ�״̬ID[" + s.stateID + "]�Ѿ����");
                return;
            }
        }
        mStates.Add(state);
    }

    public void DeleteState(EnemyStateID stateID)
    {
        if (stateID == EnemyStateID.NullState)
        {
            UnityEngine.Debug.LogError("Ҫɾ����״̬IDΪ��" + stateID);
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
        UnityEngine.Debug.LogError("Ҫɾ����StatedID[" + stateID + "]�����ڼ�����");
    }    // һ�㲻��Ҫɾ��״̬;
    public void PerformTransition(EnemyTransition trans)
    {
        if (trans == EnemyTransition.NullTransition)
        {
            UnityEngine.Debug.LogError("Ҫת��������Ϊ��:" + trans);
            return;
        }
        EnemyStateID nextStateID = mCurrentState.GetOutPutState(trans);
        if (nextStateID == EnemyStateID.NullState)
        {
            UnityEngine.Debug.LogError("��ת������ [" + trans + "] �£�û�ж�Ӧ��ת��״̬");
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
