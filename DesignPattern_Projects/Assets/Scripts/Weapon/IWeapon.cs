using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public abstract class IWeapon
{
    protected int mAtk;
    protected float mAtkRange;
    // protected int mAtkPlusValue; // 额外的暴击率是随机获得的

    protected GameObject mGameObject;
    protected ICharacter mOwner;

    protected ParticleSystem mPariticle;
    protected LineRenderer mLine;
    protected Light mLight;
    protected AudioSource mAudio;

    protected float mEffectDisplayTime;

    public float atkRange { get { return mAtkRange; } }
    public int atk { get { return mAtk; } }

    public void Update()
    {
        if (mEffectDisplayTime > 0)
        {
            mEffectDisplayTime -= Time.deltaTime;
            if (mEffectDisplayTime <= 0)
            {
                DisableEffect();
            }
        }
    }

    private void DisableEffect()
    {
        mLine.enabled = false;
        mLine.enabled = false;
    }

    // public abstract void Fire(Vector3 targetPosition);
    // 使用模板方法模式，就不能是抽象方法了
    public virtual void Fire(Vector3 targetPosition)
    {
        // 显示枪口特效
        PlayMuzzleEffect();
        // 显示子弹轨迹特效
        PlayBulletEffect(targetPosition);
        // 设置特效显示时间

        // 播放声音
        PlauSound();
    }

    protected abstract void SetEffectDisplayTime();

    protected virtual void PlayMuzzleEffect()
    {
        mPariticle.Stop();
        mPariticle.Play();
        mLight.enabled = true;
    }

    protected abstract void PlayBulletEffect(Vector3 targetPosition);

    protected void DoPlayBulletEffect(float width, Vector3 targetPosition)
    {
        mLine.enabled = true;
        mLine.startWidth = width; mLine.endWidth = width;
        mLine.SetPosition(0, mGameObject.transform.position);
        mLine.SetPosition(1, targetPosition);
    }

    protected abstract void PlauSound();

    protected void DoPlaySound(string clipName)
    {
        AudioClip clip = null;// TODO
        mAudio.clip = clip;
        mAudio.Play();
    }
}
