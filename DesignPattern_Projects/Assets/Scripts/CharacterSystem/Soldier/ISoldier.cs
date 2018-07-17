using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ISoldier : ICharacter
{
    protected SoldierFSMSystem mFSMSystem;

    public ISoldier() : base()
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
        mFSMSystem = new SoldierFSMSystem();
        SoldierIdleState idleState = new SoldierIdleState(mFSMSystem, this);
        idleState.AddTransiiton(SoldierTransition.SeeEnemy, SoldierStateID.Chase);

        SoldierChaseState chaseState = new SoldierChaseState(mFSMSystem, this);
        chaseState.AddTransiiton(SoldierTransition.NoEnemy, SoldierStateID.Idle);
        chaseState.AddTransiiton(SoldierTransition.CanAttack, SoldierStateID.Attack);

        SoldierAttackState attackState = new SoldierAttackState(mFSMSystem, this);
        attackState.AddTransiiton(SoldierTransition.NoEnemy, SoldierStateID.Idle);
        attackState.AddTransiiton(SoldierTransition.SeeEnemy, SoldierStateID.Chase);

        mFSMSystem.AddState(idleState, chaseState, attackState);
    }
}
