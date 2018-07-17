using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public abstract class ICharacter
{
    protected ICharacterAttr mAttr;
    protected GameObject mGameObject;
    protected NavMeshAgent mNavAgent;
    protected AudioSource mAudio;
    protected Animation mAnim;
    protected IWeapon mWeapon;
    public IWeapon weapon { set { mWeapon = value; }}

    public Vector3 position
    {
        get
        {
            if (mGameObject == null)
            {
                BaseLog.LogError("mGameObject 为空");
                return Vector3.zero;
            }
            return mGameObject.transform.position;
        }
    }
    public float atkRange { get { return mWeapon.atkRange; } }
    public abstract void UpdateFSMAI(List<ICharacter> targets);

    public void Update()
    {
        mWeapon.Update();
    }

    public void Attack(ICharacter target)
    {
        mWeapon.Fire(target.position);
        mGameObject.transform.LookAt(target.position);
        PlayAnim("attack");
        target.UnderAttack(mWeapon.atk + mAttr.critValue);
    }

    public virtual void UnderAttack(int damage)
    {
        mAttr.TakeDamage(damage);

        // 攻击的效果： 视效 只有敌人有

        // 死亡效果：音效 视效 只有战士有


    }

    public void PlayAnim(string animName)
    {
        mAnim.CrossFade(animName);
    }

    public void MoveTo(Vector3 targetPosition)
    {
        mNavAgent.SetDestination(targetPosition);
        PlayAnim("move");
    }
}
