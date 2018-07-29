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
            UnityEngine.Debug.LogError("EnemyTransition Error:trans ����Ϊ��"); return;
        }
        if (id == EnemyStateID.NullState)
        {
            UnityEngine.Debug.LogError("EnemyTransition Error:id״̬ ����Ϊ��"); return;
        }
        if (mMap.ContainsKey(trans))
        {
            UnityEngine.Debug.LogError("EnemyTransition Error: " + trans + "�Ѿ��������"); return;
        }

        mMap.Add(trans, id);
    }

    public void DeleteTransition(EnemyTransition trans)
    {
        if (mMap.ContainsKey(trans) == false)
        {
            UnityEngine.Debug.LogError("ɾ��ת��������ʱ��ת������[" + trans + "]������"); return;
        }
        mMap.Remove(trans);
    }

    public EnemyStateID GetOutPutState(EnemyTransition trans)
    {
        if (mMap.ContainsKey(trans) == false)
        {
            UnityEngine.Debug.LogError("ת������[" + trans + "]������"); return EnemyStateID.NullState;
        }
        else
        {
            return mMap[trans];
        }
    }

    public virtual void DoBeforeEntering() { }
    public virtual void DoBeforeLeaving() { }

    public abstract void Reason(List<ICharacter> targets); // �����жϵ�ǰ״̬�Ƿ�ת�������״̬
    public abstract void Act(List<ICharacter> targets); // ��ǰ״̬ÿִ֡�е�����

}
