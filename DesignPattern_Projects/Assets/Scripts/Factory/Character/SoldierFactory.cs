using System;
using System.Collections.Generic;
using UnityEngine;

public class SoldierFactory : ICharacterFactory
{
    public ICharacter CreateCharacter<T>(WeaponType weaponType, Vector3 spawnPosition, int lv = 1) where T : ICharacter, new()
    {
        ICharacter character = new T();

        // 创建角色游戏物体
        // 1、加载 2、实例化 TODO

        // 添加武器 TODO

        int maxHP = 0;
        float moveSpeed = 0;
        string name = null, iconSprite = null, prefanName = null;

        System.Type t = typeof(T);

        if (t == typeof(Soldier_Captain))
        {
            name = "上尉士兵";
            iconSprite = "CaptainIcon";
            prefanName = "Soldier1";
            moveSpeed = 3;
            maxHP = 100;
        }

        else if(t == typeof(Soldier_Sergeant))
        {
            name = "中士士兵";
            iconSprite = "SergeantIcon";
            prefanName = "Soldier3";
            moveSpeed = 3;
            maxHP = 90;
        }

        else if (t == typeof(Soldier_Rokie))
        {
            name = "新手士兵";
            iconSprite = "RokieIcon";
            prefanName = "Soldier2";
            moveSpeed = 2.5f;
            maxHP = 80;
        }

        else
        {
            Debug.LogError("类型" + t + "不属于ISoldier，无法创建战士");
            return null;
        }

        ICharacterAttr attr = new SoldierAttr(new SoldierAttrStrategy(), name, maxHP, moveSpeed, iconSprite, prefanName);
        character.attr = attr;
        return character;
    }
}