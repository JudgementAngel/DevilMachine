using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

class SoldierBuilder : ICharacterBuilder
{
    public SoldierBuilder(ICharacter character, Type t, WeaponType weaponType, Vector3 spawnPosition, int lv) : base(character, t, weaponType, spawnPosition, lv)
    {
    }

    public override void AddCharacterAttr()
    {
        CharacterBaseAttr baseAttr = FactoryManager.AttrFactory.GetCahCharacterBaseAttr(mT);
        mPrefabName = baseAttr.prefabName; // 下面的构造需要这个

        ICharacterAttr attr = new SoldierAttr(new SoldierAttrStrategy(), mLv, baseAttr);
        mCharacter.attr = attr;
    }

    public override void AddGameObject()
    {
        // 创建角色游戏物体
        // 1、加载 2、实例化 
        GameObject characterGO = FactoryManager.AssetFactory.LoadSoldier(mPrefabName);
        characterGO.transform.position = mSpawnPosition;
        mCharacter.gameObject = characterGO;
    }

    public override void AddWeapon()
    {
        // 添加武器
        IWeapon weapon = FactoryManager.WeaponFactory.CreateWeapon(mWeaponType);
        mCharacter.weapon = weapon;
    }

    public override void AddInCharacterSystem()
    {
        GameFacade.Instance.AddSoldier(mCharacter as ISoldier);
    }

    public override ICharacter GetResult()
    {
        return mCharacter;
    }
}
