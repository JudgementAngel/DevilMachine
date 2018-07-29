using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class CharacterBaseAttr
{
    private string mName;
    protected int mMaxHP;
    protected float mMoveSpeed;
    protected string mIconSprite;
    protected string mPrefabName;
    protected float mCritRate; // 0 - 1的暴击率，只有敌人才有;

    public string name { get { return mName; } }
    public int maxHP { get { return mMaxHP; } }
    public float moveSpeed { get { return mMoveSpeed; } }
    public string iconSprite { get { return mIconSprite; } }
    public string prefabName { get { return mPrefabName; } }
    public float critRate { get { return mCritRate; } }


    public CharacterBaseAttr(string name, int maxHP, float moveSpeed, string iconSprite, string prefabName, float critRate)
    {
        mName = name;
        mMaxHP = maxHP;
        mMoveSpeed = moveSpeed;
        mIconSprite = iconSprite;
        mPrefabName = prefabName;
        mCritRate = critRate;
    }


}
