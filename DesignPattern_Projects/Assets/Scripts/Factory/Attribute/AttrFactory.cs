using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class AttrFactory : IAttrFactory
{
    private Dictionary<Type, CharacterBaseAttr> mCharacterBaseAttrDict;
    private Dictionary<WeaponType, WeaponBaseAttr> mWeaponBaseAttrDict;

    public AttrFactory()
    {
        InitCharacterBaseAttr();
        InitWeaponBaseAttr();
    }

    private void InitWeaponBaseAttr()
    {
        mWeaponBaseAttrDict = new Dictionary<WeaponType, WeaponBaseAttr>();

        mWeaponBaseAttrDict.Add(WeaponType.Gun, new WeaponBaseAttr("��ǹ",20,5,"WeaponGun"));
        mWeaponBaseAttrDict.Add(WeaponType.Rifle, new WeaponBaseAttr("��ǹ",30,7,"WeaponRifle"));
        mWeaponBaseAttrDict.Add(WeaponType.Rocket, new WeaponBaseAttr("���",40,8,"WeaponRocket"));
    }

    private void InitCharacterBaseAttr()
    {
        mCharacterBaseAttrDict = new Dictionary<Type, CharacterBaseAttr>();

        // Soldier
        mCharacterBaseAttrDict.Add(typeof(Soldier_Rookie),new CharacterBaseAttr("����ʿ��",80,2.5f, "RokieIcon", "Soldier2",0));
        mCharacterBaseAttrDict.Add(typeof(Soldier_Sergeant), new CharacterBaseAttr("��ʿʿ��", 90, 3f, "SergeantIcon", "Soldier3", 0));
        mCharacterBaseAttrDict.Add(typeof(Soldier_Captain), new CharacterBaseAttr("��ξʿ��", 100, 3f, "CaptainIcon", "Soldier1", 0));

        // Enemy
        mCharacterBaseAttrDict.Add(typeof(Enemy_Elf), new CharacterBaseAttr("С����", 100, 3, "ElfIcon", "Enemy1", 0.2f));
        mCharacterBaseAttrDict.Add(typeof(Enemy_Ogre), new CharacterBaseAttr("����", 120, 2, "OgreIcon", "Enemy2", 0.3f));
        mCharacterBaseAttrDict.Add(typeof(Enemy_Troll), new CharacterBaseAttr("��ħ", 200, 1, "TrollIcon", "Enemy3", 0.4f));
    }

    public CharacterBaseAttr GetCahCharacterBaseAttr(Type t)
    {
        if (mCharacterBaseAttrDict.ContainsKey(t) == false)
        {
            Debug.LogError("�޷��������ͣ�"+t+"�õ���ɫ��������(GetCharacterBaseAttr)");
            return null;
        }
        return mCharacterBaseAttrDict[t];
    }

    public WeaponBaseAttr GetWeaponBaseAttr(WeaponType weaponType)
    {
        if (mWeaponBaseAttrDict.ContainsKey(weaponType) == false)
        {
            Debug.LogError("�޷��������ͣ�" + weaponType + "�õ�������������(GetWeaponBaseAttr)");
            return null;
        }
        return mWeaponBaseAttrDict[weaponType];
    }
}
