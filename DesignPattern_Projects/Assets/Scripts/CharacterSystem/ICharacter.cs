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

    protected bool mIsKilled = false;
    public bool isKilled { get { return mIsKilled; } }

    protected bool mCanDestory = false;
    protected float mDestoryTime = 2.0f;
    protected float mDestoryTimer = 2.0f;

    public bool canDestory { get { return mCanDestory; } }

    public IWeapon weapon
    {
        get { return mWeapon; }
        set
        {
            mWeapon = value;
            mWeapon.owner = this;
            GameObject child = UnityTool.FindChild(mGameObject, "weapon-point");
            UnityTool.Attach(child,mWeapon.gameObject);
        }
    }

    public Vector3 position
    {
        get
        {
            if (mGameObject == null)
            {
                Debug.LogError("mGameObject 为空");
                return Vector3.zero;
            }
            return mGameObject.transform.position;
        }
    }
    public float atkRange { get { return mWeapon.atkRange; } }
    public ICharacterAttr attr { get { return mAttr; } set { mAttr = value; } }

    public GameObject gameObject
    {
        get { return mGameObject; }
        set
        {
            mGameObject = value;
            mNavAgent = mGameObject.GetComponent<NavMeshAgent>();
            mAudio = mGameObject.GetComponent<AudioSource>();
            mAnim = mGameObject.GetComponentInChildren<Animation>();
        }
    }

    public abstract void UpdateFSMAI(List<ICharacter> targets);
    public abstract void RunVisitor(ICharacterVisitor visitor);

    public void Update()
    {
        if (mIsKilled)
        {
            mDestoryTimer -= Time.deltaTime;
            if (mDestoryTimer <= 0)
            {
                mDestoryTimer = mDestoryTime;
                mCanDestory = true;
            }
            return;
        }
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

    protected void DoPlayEffect(string effectName)
    {
        // 第一步 加载特效
        GameObject effectGO = FactoryManager.AssetFactory.LoadEffect(effectName);
        effectGO.transform.position = position;
        // 控制销毁
        effectGO.AddComponent<DestoryForTime>();
    }


    protected void DoPlaySound(string soundName)
    {
        AudioClip clip = FactoryManager.AssetFactory.LoadAudioClip(soundName);
        mAudio.clip = clip;
        mAudio.Play();
    }

    public virtual void Killed()
    {
        mIsKilled = true;
        mNavAgent.isStopped = true;
    }

    public void Release()
    {
        GameObject.Destroy(mGameObject);
    }

    public abstract void PlaySound();
    public abstract void PlayEffect();
}
