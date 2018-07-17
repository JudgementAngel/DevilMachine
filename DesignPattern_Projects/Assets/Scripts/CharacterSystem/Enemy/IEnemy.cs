using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class IEnemy : ICharacter
{
    protected EnemyFSMSystem mFSMSystem;

    public IEnemy()
    {
        MakeFSM();
    }

    public override void UpdateFSMAI(List<ICharacter> targets)
    {
        mFSMSystem.CurrentState.Reason(targets);
        mFSMSystem.CurrentState.Act(targets);
    }

    private void MakeFSM()
    {
        mFSMSystem = new EnemyFSMSystem();
        EnemyChaseState chaseState = new EnemyChaseState(mFSMSystem,this);
        chaseState.AddTransiiton(EnemyTransition.CanAttack, EnemyStateID.Attack);
        
        EnemyAttackState attackState = new EnemyAttackState(mFSMSystem,this);
        attackState.AddTransiiton(EnemyTransition.LostSoldier, EnemyStateID.Chase);

        mFSMSystem.AddState(chaseState,attackState);
    }

    public override void UnderAttack(int damage)
    {
        base.UnderAttack(damage);
        PlayEffect();
    }

    protected abstract void PlayEffect();

    protected void DOPlayEffect(string effectName )
    {
        // 第一步 加载特效 TODO
        GameObject effectGO;
        // 控制销毁 TODO
    }
}
